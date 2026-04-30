import { useEffect, useMemo, useState } from 'react';
import {
  AlertTriangle,
  BarChart3,
  Boxes,
  CheckCircle2,
  Edit3,
  LayoutDashboard,
  LockKeyhole,
  LogOut,
  PackagePlus,
  Plus,
  RefreshCw,
  Shield,
  ShoppingBag,
  Trash2,
  Undo2,
  UserCog
} from 'lucide-react';
import { adminApi, authApi, clearSession, getSavedUser, saveSession } from './api.js';

const emptyProduct = {
  name: '',
  description: '',
  category: '',
  imageUrl: '',
  price: '',
  stock: ''
};

function money(value) {
  const number = Number(value || 0);
  return `$${number.toFixed(2)}`;
}

function formatDate(value) {
  if (!value) return '—';
  return new Intl.DateTimeFormat('en', {
    dateStyle: 'medium',
    timeStyle: 'short'
  }).format(new Date(value));
}

function App() {
  const [user, setUser] = useState(getSavedUser());
  const [authMode, setAuthMode] = useState('login');
  const [authForm, setAuthForm] = useState({ fullName: '', email: '', password: '' });
  const [bootstrapKey, setBootstrapKey] = useState(import.meta.env.VITE_ADMIN_BOOTSTRAP_KEY || 'change-me-admin-bootstrap-key');
  const [products, setProducts] = useState([]);
  const [orders, setOrders] = useState([]);
  const [activePanel, setActivePanel] = useState('overview');
  const [productForm, setProductForm] = useState(emptyProduct);
  const [editingProductId, setEditingProductId] = useState(null);
  const [loading, setLoading] = useState(false);
  const [notice, setNotice] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    if (user) {
      refreshAll();
    }
  }, [user]);

  const metrics = useMemo(() => {
    const stockUnits = products.reduce((sum, item) => sum + Number(item.stock || 0), 0);
    const lowStock = products.filter((item) => Number(item.stock || 0) <= 5).length;
    const revenue = orders.reduce((sum, order) => sum + Number(order.totalAmount || 0), 0);
    const returned = orders.filter((order) => order.status === 'RETURNED').length;

    return { stockUnits, lowStock, revenue, returned };
  }, [products, orders]);

  async function run(action, successMessage) {
    setLoading(true);
    setError('');
    setNotice('');
    try {
      const result = await action();
      if (successMessage) setNotice(successMessage);
      return result;
    } catch (err) {
      setError(err.message || 'Something went wrong');
      return null;
    } finally {
      setLoading(false);
    }
  }

  async function refreshProducts() {
    return run(async () => {
      const data = await adminApi.products();
      setProducts(Array.isArray(data) ? data : []);
    });
  }

  async function refreshOrders() {
    return run(async () => {
      const data = await adminApi.orders();
      setOrders(Array.isArray(data) ? data : []);
    });
  }

  async function refreshAll() {
    return run(async () => {
      const [productData, orderData] = await Promise.all([
        adminApi.products(),
        adminApi.orders()
      ]);
      setProducts(Array.isArray(productData) ? productData : []);
      setOrders(Array.isArray(orderData) ? orderData : []);
    });
  }

  async function submitAuth(event) {
    event.preventDefault();
    const payload = {
      email: authForm.email,
      password: authForm.password,
      ...(authMode === 'register' ? { fullName: authForm.fullName } : {})
    };

    await run(async () => {
      const response = authMode === 'register'
        ? await authApi.registerAdmin(payload, bootstrapKey)
        : await authApi.loginAdmin(payload);

      saveSession(response);
      setUser({ id: response.userId, email: response.email, role: response.role });
      setAuthForm({ fullName: '', email: '', password: '' });
      setActivePanel('overview');
    }, authMode === 'register' ? 'Admin account created.' : 'Logged in successfully.');
  }

  function logout() {
    clearSession();
    setUser(null);
    setProducts([]);
    setOrders([]);
    setNotice('Logged out.');
  }

  function editProduct(product) {
    setEditingProductId(product.id);
    setProductForm({
      name: product.name || '',
      description: product.description || '',
      category: product.category || '',
      imageUrl: product.imageUrl || '',
      price: product.price || '',
      stock: product.stock || ''
    });
    setActivePanel('products');
  }

  function resetProductForm() {
    setEditingProductId(null);
    setProductForm(emptyProduct);
  }

  async function submitProduct(event) {
    event.preventDefault();
    const payload = {
      name: productForm.name,
      description: productForm.description,
      category: productForm.category,
      imageUrl: productForm.imageUrl,
      price: Number(productForm.price),
      stock: Number(productForm.stock)
    };

    await run(async () => {
      if (editingProductId) {
        await adminApi.updateProduct(editingProductId, payload);
      } else {
        await adminApi.createProduct(payload);
      }
      resetProductForm();
      await refreshProducts();
    }, editingProductId ? 'Product updated.' : 'Product created.');
  }

  async function deleteProduct(id) {
    const confirmed = window.confirm('Delete this product?');
    if (!confirmed) return;

    await run(async () => {
      await adminApi.deleteProduct(id);
      await refreshProducts();
    }, 'Product deleted.');
  }

  async function markReturned(orderId) {
    await run(async () => {
      await adminApi.markReturned(orderId);
      await Promise.all([refreshOrders(), refreshProducts()]);
    }, `Order #${orderId} marked as returned.`);
  }

  if (!user) {
    return (
      <div className="login-page">
        <section className="login-hero">
          <div className="logo-tile"><ShoppingBag size={28} /></div>
          <p className="eyebrow">ShopCloud internal</p>
          <h1>Admin dashboard for inventory and order operations.</h1>
          <p>
            This interface is intentionally separate from the customer storefront. In production, expose it only through the private/internal path.
          </p>
          <div className="security-strip">
            <div><Shield size={18} /> Admin JWT</div>
            <div><LockKeyhole size={18} /> Private entry point</div>
            <div><Boxes size={18} /> Inventory control</div>
          </div>
        </section>

        <section className="auth-card">
          <p className="eyebrow">Administrator access</p>
          <h2>{authMode === 'login' ? 'Login' : 'Create admin'}</h2>

          {(notice || error) && <div className={`message ${error ? 'error' : 'success'}`}>{error || notice}</div>}

          <form className="stack-form" onSubmit={submitAuth}>
            {authMode === 'register' && (
              <>
                <label>
                  Full name
                  <input value={authForm.fullName} onChange={(e) => setAuthForm({ ...authForm, fullName: e.target.value })} required />
                </label>
                <label>
                  Admin bootstrap key
                  <input value={bootstrapKey} onChange={(e) => setBootstrapKey(e.target.value)} required />
                </label>
              </>
            )}
            <label>
              Email
              <input type="email" value={authForm.email} onChange={(e) => setAuthForm({ ...authForm, email: e.target.value })} required />
            </label>
            <label>
              Password
              <input type="password" value={authForm.password} onChange={(e) => setAuthForm({ ...authForm, password: e.target.value })} required minLength={4} />
            </label>
            <button className="primary-button" type="submit" disabled={loading}>
              {authMode === 'login' ? 'Login to dashboard' : 'Create admin account'}
            </button>
            <button className="link-button" type="button" onClick={() => setAuthMode(authMode === 'login' ? 'register' : 'login')}>
              {authMode === 'login' ? 'Need to bootstrap an admin?' : 'Already have an admin account?'}
            </button>
          </form>
        </section>
      </div>
    );
  }

  return (
    <div className="admin-shell">
      <aside className="sidebar">
        <div className="sidebar-brand">
          <div className="logo-tile"><ShoppingBag size={22} /></div>
          <div>
            <p className="eyebrow">ShopCloud</p>
            <h1>Admin</h1>
          </div>
        </div>

        <nav className="side-nav">
          <button className={activePanel === 'overview' ? 'active' : ''} onClick={() => setActivePanel('overview')}><LayoutDashboard size={19} /> Overview</button>
          <button className={activePanel === 'products' ? 'active' : ''} onClick={() => setActivePanel('products')}><Boxes size={19} /> Products</button>
          <button className={activePanel === 'orders' ? 'active' : ''} onClick={() => setActivePanel('orders')}><ShoppingBag size={19} /> Orders</button>
        </nav>

        <div className="sidebar-footer">
          <div className="admin-user">
            <UserCog size={18} />
            <span>{user.email}</span>
          </div>
          <button className="ghost-button" onClick={logout}><LogOut size={17} /> Logout</button>
        </div>
      </aside>

      <main className="dashboard-main">
        <header className="topbar">
          <div>
            <p className="eyebrow">Internal operations</p>
            <h2>{activePanel === 'overview' ? 'Dashboard overview' : activePanel === 'products' ? 'Product management' : 'Order management'}</h2>
          </div>
          <button className="primary-button" onClick={refreshAll} disabled={loading}><RefreshCw size={17} /> Refresh</button>
        </header>

        {(notice || error) && <div className={`message ${error ? 'error' : 'success'}`}>{error || notice}</div>}

        {activePanel === 'overview' && (
          <section className="overview-grid">
            <MetricCard icon={<Boxes />} label="Products" value={products.length} text="Catalog entries" />
            <MetricCard icon={<BarChart3 />} label="Stock units" value={metrics.stockUnits} text="Available inventory" />
            <MetricCard icon={<ShoppingBag />} label="Orders" value={orders.length} text="Recorded checkouts" />
            <MetricCard icon={<Undo2 />} label="Returned" value={metrics.returned} text="Return requests processed" />

            <div className="panel span-2">
              <div className="panel-header">
                <div>
                  <p className="eyebrow">Inventory watch</p>
                  <h3>Low stock products</h3>
                </div>
                <button className="secondary-button" onClick={() => setActivePanel('products')}>Manage products</button>
              </div>
              {products.filter((p) => Number(p.stock || 0) <= 5).length === 0 ? (
                <EmptyState icon={<CheckCircle2 />} title="Inventory looks healthy" text="No product is currently at or below 5 units." />
              ) : (
                <div className="table-card">
                  <table>
                    <thead><tr><th>Product</th><th>Category</th><th>Stock</th><th>Price</th></tr></thead>
                    <tbody>
                      {products.filter((p) => Number(p.stock || 0) <= 5).map((product) => (
                        <tr key={product.id}>
                          <td>{product.name}</td>
                          <td>{product.category}</td>
                          <td><span className="danger-pill">{product.stock}</span></td>
                          <td>{money(product.price)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>

            <div className="panel">
              <p className="eyebrow">Revenue snapshot</p>
              <h3>{money(metrics.revenue)}</h3>
              <p className="muted">Total recorded order value from checkout-service.</p>
              <div className="revenue-bar"><span style={{ width: `${Math.min(100, orders.length * 15)}%` }} /></div>
            </div>
          </section>
        )}

        {activePanel === 'products' && (
          <section className="products-grid">
            <div className="panel form-panel">
              <p className="eyebrow"><PackagePlus size={14} /> {editingProductId ? 'Edit product' : 'New product'}</p>
              <h3>{editingProductId ? `Editing product #${editingProductId}` : 'Add catalog item'}</h3>
              <form className="stack-form" onSubmit={submitProduct}>
                <label>Name<input value={productForm.name} onChange={(e) => setProductForm({ ...productForm, name: e.target.value })} required /></label>
                <label>Category<input value={productForm.category} onChange={(e) => setProductForm({ ...productForm, category: e.target.value })} required /></label>
                <label>Description<textarea value={productForm.description} onChange={(e) => setProductForm({ ...productForm, description: e.target.value })} rows="4" /></label>
                <label>Image URL<input value={productForm.imageUrl} onChange={(e) => setProductForm({ ...productForm, imageUrl: e.target.value })} placeholder="https://..." /></label>
                <div className="two-fields">
                  <label>Price<input type="number" min="0" step="0.01" value={productForm.price} onChange={(e) => setProductForm({ ...productForm, price: e.target.value })} required /></label>
                  <label>Stock<input type="number" min="0" step="1" value={productForm.stock} onChange={(e) => setProductForm({ ...productForm, stock: e.target.value })} required /></label>
                </div>
                <button className="primary-button" type="submit" disabled={loading}>{editingProductId ? 'Save changes' : 'Create product'}</button>
                {editingProductId && <button className="secondary-button" type="button" onClick={resetProductForm}>Cancel edit</button>}
              </form>
            </div>

            <div className="panel table-panel">
              <div className="panel-header">
                <div>
                  <p className="eyebrow">Catalog</p>
                  <h3>{products.length} products</h3>
                </div>
                <button className="ghost-button" onClick={refreshProducts}><RefreshCw size={16} /> Refresh</button>
              </div>

              {products.length === 0 ? (
                <EmptyState icon={<Boxes />} title="No products yet" text="Create the first product using the form on the left." />
              ) : (
                <div className="table-card">
                  <table>
                    <thead>
                      <tr><th>Product</th><th>Category</th><th>Price</th><th>Stock</th><th>Actions</th></tr>
                    </thead>
                    <tbody>
                      {products.map((product) => (
                        <tr key={product.id}>
                          <td>
                            <div className="product-cell">
                              <div className="thumb" style={{ backgroundImage: `url(${product.imageUrl || 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=600&q=80'})` }} />
                              <div><strong>{product.name}</strong><span>#{product.id}</span></div>
                            </div>
                          </td>
                          <td>{product.category}</td>
                          <td>{money(product.price)}</td>
                          <td>{Number(product.stock) <= 5 ? <span className="danger-pill">{product.stock}</span> : <span className="ok-pill">{product.stock}</span>}</td>
                          <td>
                            <div className="row-actions">
                              <button className="icon-button" onClick={() => editProduct(product)} title="Edit"><Edit3 size={16} /></button>
                              <button className="icon-button danger" onClick={() => deleteProduct(product.id)} title="Delete"><Trash2 size={16} /></button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </section>
        )}

        {activePanel === 'orders' && (
          <section className="panel">
            <div className="panel-header">
              <div>
                <p className="eyebrow">Checkout service</p>
                <h3>{orders.length} orders</h3>
              </div>
              <button className="ghost-button" onClick={refreshOrders}><RefreshCw size={16} /> Refresh</button>
            </div>

            {orders.length === 0 ? (
              <EmptyState icon={<ShoppingBag />} title="No orders yet" text="Customer checkouts will appear here after the checkout service records them." />
            ) : (
              <div className="orders-list">
                {orders.map((order) => (
                  <article className="order-card" key={order.id}>
                    <div className="order-main">
                      <div>
                        <p className="eyebrow">Order #{order.id}</p>
                        <h3>{money(order.totalAmount)}</h3>
                        <p className="muted">Customer #{order.userId} • {formatDate(order.createdAt)}</p>
                      </div>
                      <div className="order-status-block">
                        <span className={order.status === 'RETURNED' ? 'danger-pill' : 'ok-pill'}>{order.status}</span>
                        {order.status !== 'RETURNED' && (
                          <button className="secondary-button" onClick={() => markReturned(order.id)}><Undo2 size={16} /> Mark returned</button>
                        )}
                      </div>
                    </div>
                    <div className="order-lines">
                      {(order.items || []).map((line) => (
                        <div key={line.id || line.productId}>
                          <span>{line.productName}</span>
                          <strong>{line.quantity} × {money(line.unitPrice)}</strong>
                        </div>
                      ))}
                    </div>
                  </article>
                ))}
              </div>
            )}
          </section>
        )}

        {metrics.lowStock > 0 && (
          <div className="floating-warning">
            <AlertTriangle size={17} /> {metrics.lowStock} product{metrics.lowStock === 1 ? '' : 's'} low on stock
          </div>
        )}
      </main>
    </div>
  );
}

function MetricCard({ icon, label, value, text }) {
  return (
    <article className="metric-card">
      <div className="metric-icon">{icon}</div>
      <p>{label}</p>
      <strong>{value}</strong>
      <span>{text}</span>
    </article>
  );
}

function EmptyState({ icon, title, text }) {
  return (
    <div className="empty-state">
      <div>{icon}</div>
      <h4>{title}</h4>
      <p>{text}</p>
    </div>
  );
}

export default App;
