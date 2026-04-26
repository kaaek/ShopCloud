const TOKEN_KEY = 'shopcloud_admin_token';
const USER_KEY = 'shopcloud_admin_user';

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
  registerAdmin: (payload, bootstrapKey) => request('/api/auth/admin/register', {
    method: 'POST',
    headers: {
      'X-Admin-Bootstrap-Key': bootstrapKey
    },
    body: JSON.stringify(payload)
  }),
  loginAdmin: (payload) => request('/api/auth/admin/login', {
    method: 'POST',
    body: JSON.stringify(payload)
  }),
  me: () => request('/api/auth/me')
};

export const adminApi = {
  products: () => request('/api/admin/products'),
  createProduct: (payload) => request('/api/admin/products', {
    method: 'POST',
    body: JSON.stringify(payload)
  }),
  updateProduct: (id, payload) => request(`/api/admin/products/${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload)
  }),
  deleteProduct: (id) => request(`/api/admin/products/${id}`, {
    method: 'DELETE'
  }),
  orders: () => request('/api/admin/orders'),
  markReturned: (id) => request(`/api/admin/orders/${id}/return`, {
    method: 'POST'
  })
};
