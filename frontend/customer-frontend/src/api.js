const TOKEN_KEY = 'shopcloud_customer_token';
const USER_KEY = 'shopcloud_customer_user';

export function getToken() {
  return localStorage.getItem(TOKEN_KEY);
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

export function saveSession(authResponse) {
  localStorage.setItem(TOKEN_KEY, authResponse.token);
  localStorage.setItem(USER_KEY, JSON.stringify({
    id: authResponse.userId,
    email: authResponse.email,
    role: authResponse.role
  }));
}

export function clearSession() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

async function request(path, options = {}) {
  const token = getToken();
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

  if (!response.ok) {
    const message = typeof data === 'string'
      ? data
      : data?.message || data?.error || `Request failed with status ${response.status}`;
    throw new Error(message);
  }

  return data;
}

export const authApi = {
  register: (payload) => request('/api/auth/register', {
    method: 'POST',
    body: JSON.stringify(payload)
  }),
  login: (payload) => request('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify(payload)
  }),
  me: () => request('/api/auth/me')
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
