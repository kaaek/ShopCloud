// ————————— Cognito Configuration ————————— //
// These values should be provided as environment variables
const COGNITO_CONFIG = {
  userPoolId: import.meta.env.VITE_COGNITO_USER_POOL_ID || process.env.REACT_APP_COGNITO_USER_POOL_ID,
  clientId: import.meta.env.VITE_COGNITO_CLIENT_ID || process.env.REACT_APP_COGNITO_CLIENT_ID,
  region: import.meta.env.VITE_COGNITO_REGION || process.env.REACT_APP_COGNITO_REGION || 'us-east-1',
  domain: import.meta.env.VITE_COGNITO_DOMAIN || process.env.REACT_APP_COGNITO_DOMAIN,
  redirectSignIn: import.meta.env.VITE_REDIRECT_URI || `${window.location.origin}/callback`,
  redirectSignOut: import.meta.env.VITE_REDIRECT_SIGN_OUT || window.location.origin
};

const TOKEN_KEY = 'shopcloud_customer_id_token';
const ACCESS_TOKEN_KEY = 'shopcloud_customer_access_token';
const REFRESH_TOKEN_KEY = 'shopcloud_customer_refresh_token';
const USER_KEY = 'shopcloud_customer_user';

// ————————— Session Management ————————— //
export function getIdToken() {
  return localStorage.getItem(TOKEN_KEY);
}

export function getAccessToken() {
  return localStorage.getItem(ACCESS_TOKEN_KEY);
}

export function getRefreshToken() {
  return localStorage.getItem(REFRESH_TOKEN_KEY);
}

export function getSavedUser() {
  const raw = localStorage.getItem(USER_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

export function saveSession(tokens, user) {
  if (tokens.idToken) localStorage.setItem(TOKEN_KEY, tokens.idToken);
  if (tokens.accessToken) localStorage.setItem(ACCESS_TOKEN_KEY, tokens.accessToken);
  if (tokens.refreshToken) localStorage.setItem(REFRESH_TOKEN_KEY, tokens.refreshToken);
  
  if (user) {
    localStorage.setItem(USER_KEY, JSON.stringify(user));
  }
}

export function clearSession() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(ACCESS_TOKEN_KEY);
  localStorage.removeItem(REFRESH_TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

// ————————— Cognito OAuth Flow ————————— //
export function getLoginUrl() {
  const domain = COGNITO_CONFIG.domain;
  const clientId = COGNITO_CONFIG.clientId;
  const redirectUri = COGNITO_CONFIG.redirectSignIn;
  
  return `https://${domain}/oauth2/authorize?client_id=${clientId}&response_type=code&scope=openid+email+profile&redirect_uri=${encodeURIComponent(redirectUri)}`;
}

export function getLogoutUrl() {
  const domain = COGNITO_CONFIG.domain;
  const clientId = COGNITO_CONFIG.clientId;
  const redirectUri = COGNITO_CONFIG.redirectSignOut;
  
  return `https://${domain}/logout?client_id=${clientId}&logout_uri=${encodeURIComponent(redirectUri)}`;
}

// Exchange authorization code for tokens
export async function exchangeCodeForTokens(code) {
  const domain = COGNITO_CONFIG.domain;
  const clientId = COGNITO_CONFIG.clientId;
  const redirectUri = COGNITO_CONFIG.redirectSignIn;

  try {
    const response = await fetch(`https://${domain}/oauth2/token`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        client_id: clientId,
        code: code,
        redirect_uri: redirectUri
      })
    });

    if (!response.ok) {
      throw new Error('Failed to exchange code for tokens');
    }

    const data = await response.json();
    
    // Decode JWT to get user info
    const decodedToken = decodeJWT(data.id_token);
    const user = {
      id: decodedToken.sub,
      email: decodedToken.email,
      name: decodedToken.name || decodedToken.email
    };

    saveSession({
      idToken: data.id_token,
      accessToken: data.access_token,
      refreshToken: data.refresh_token
    }, user);

    return { user, tokens: data };
  } catch (error) {
    console.error('Token exchange failed:', error);
    throw error;
  }
}

// Refresh tokens using refresh token
export async function refreshTokens() {
  const domain = COGNITO_CONFIG.domain;
  const clientId = COGNITO_CONFIG.clientId;
  const refreshToken = getRefreshToken();

  if (!refreshToken) {
    throw new Error('No refresh token available');
  }

  try {
    const response = await fetch(`https://${domain}/oauth2/token`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        client_id: clientId,
        refresh_token: refreshToken
      })
    });

    if (!response.ok) {
      throw new Error('Failed to refresh tokens');
    }

    const data = await response.json();
    
    saveSession({
      idToken: data.id_token,
      accessToken: data.access_token,
      refreshToken: data.refresh_token || refreshToken
    });

    return data;
  } catch (error) {
    console.error('Token refresh failed:', error);
    clearSession();
    throw error;
  }
}

// ————————— Utilities ————————— //
function decodeJWT(token) {
  try {
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split('')
        .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    );
    return JSON.parse(jsonPayload);
  } catch (error) {
    console.error('JWT decode error:', error);
    return {};
  }
}

export function isTokenExpired(token) {
  if (!token) return true;
  
  try {
    const decoded = decodeJWT(token);
    const expirationTime = decoded.exp * 1000; // Convert to milliseconds
    return Date.now() >= expirationTime;
  } catch {
    return true;
  }
}

// ————————— API Requests ————————— //
async function request(path, options = {}) {
  let token = getAccessToken();
  
  // Refresh token if expired
  if (token && isTokenExpired(token)) {
    try {
      await refreshTokens();
      token = getAccessToken();
    } catch {
      clearSession();
      window.location.href = getLoginUrl();
      return;
    }
  }

  const headers = {
    'Content-Type': 'application/json',
    ...(options.headers || {})
  };

  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const response = await fetch(path, {
    ...options,
    headers
  });

  if (response.status === 204) return null;

  const text = await response.text();
  let data = null;

  if (text) {
    try {
      data = JSON.parse(text);
    } catch {
      data = text;
    }
  }

  if (response.status === 401) {
    clearSession();
    window.location.href = getLoginUrl();
    throw new Error('Unauthorized - please log in');
  }

  if (!response.ok) {
    const message = typeof data === 'string'
      ? data
      : data?.message || data?.error || `Request failed with status ${response.status}`;
    throw new Error(message);
  }

  return data;
}

export const authApi = {
  me: () => request('/api/auth/me'),
  login: () => {
    window.location.href = getLoginUrl();
  },
  logout: () => {
    clearSession();
    window.location.href = getLogoutUrl();
  }
};

export const productApi = {
  all: () => request('/api/products'),
  search: ({ keyword, category }) => {
    const params = new URLSearchParams();
    if (keyword) params.set('keyword', keyword);
    if (category) params.set('category', category);
    const query = params.toString();
    return request(query ? `/api/products/search?${query}` : '/api/products');
  },
  byId: (id) => request(`/api/products/${id}`)
};

export const cartApi = {
  get: () => request('/api/cart'),
  add: (productId, quantity = 1) => request('/api/cart/items', {
    method: 'POST',
    body: JSON.stringify({ productId, quantity })
  }),
  update: (productId, quantity) => request(`/api/cart/items/${productId}`, {
    method: 'PUT',
    body: JSON.stringify({ productId, quantity })
  }),
  remove: (productId) => request(`/api/cart/items/${productId}`, {
    method: 'DELETE'
  }),
  clear: () => request('/api/cart/clear', {
    method: 'DELETE'
  })
};

export const checkoutApi = {
  checkout: () => request('/api/checkout', {
    method: 'POST'
  }),
  myOrders: () => request('/api/orders/my')
};
