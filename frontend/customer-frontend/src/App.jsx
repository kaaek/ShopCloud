import { useEffect, useMemo, useState } from 'react';
import { Navigate } from 'react-router-dom';
import {
  ArrowRight,
  Boxes,
  CheckCircle2,
  Clock3,
  CreditCard,
  LogOut,
  Package,
  Search,
  ShieldCheck,
  ShoppingBag,
  ShoppingCart,
  Sparkles,
  Trash2,
  UserRound
} from 'lucide-react';
import {
  authApi,
  cartApi,
  checkoutApi,
  clearSession,
  getSavedUser,
  getLoginUrl,
  productApi,
  saveSession
} from './api.js';

const fallbackImage = 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=1200&q=80';

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
  const [products, setProducts] = useState([]);
  const [cart, setCart] = useState([]);
  const [orders, setOrders] = useState([]);
  const [activePanel, setActivePanel] = useState('shop');
  const [keyword, setKeyword] = useState('');
  const [category, setCategory] = useState('');
  const [loading, setLoading] = useState(false);
  const [notice, setNotice] = useState('');
  const [error, setError] = useState('');

  const categories = useMemo(() => {
    return [...new Set(products.map((p) => p.category).filter(Boolean))].sort();
  }, [products]);

  const productMap = useMemo(() => {
    return new Map(products.map((p) => [Number(p.id), p]));
  }, [products]);

  const cartLines = useMemo(() => {
    return cart.map((item) => {
      const product = productMap.get(Number(item.productId));
      return {
        ...item,
        product,
        lineTotal: Number(product?.price || 0) * Number(item.quantity || 0)
      };
    });
  }, [cart, productMap]);

  const cartTotal = useMemo(() => {
    return cartLines.reduce((sum, item) => sum + item.lineTotal, 0);
  }, [cartLines]);

  useEffect(() => {
    loadProducts();
  }, []);

  useEffect(() => {
    if (user) {
      loadCart();
      loadOrders();
    } else {
      setCart([]);
      setOrders([]);
    }
  }, [user]);

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

  async function loadProducts(filters = {}) {
    return run(async () => {
      const data = await productApi.search(filters);
      setProducts(Array.isArray(data) ? data : []);
    });
  }

  async function loadCart() {
    return run(async () => {
      const data = await cartApi.get();
      setCart(Array.isArray(data) ? data : []);
    });
  }

  async function loadOrders() {
    return run(async () => {
      const data = await checkoutApi.myOrders();
      setOrders(Array.isArray(data) ? data : []);
    });
  }

  async function submitAuth(event) {
    event.preventDefault();
    // With Cognito, we don't need to handle login/register here
    // Instead, redirect to Cognito's hosted UI
    authApi.login();
  }

  function logout() {
    authApi.logout();
  }

  async function addToCart(product) {
    if (!user) {
      setActivePanel('account');
      setError('Log in or create an account before adding items to the cart.');
      return;
    }

    await run(async () => {
      await cartApi.add(product.id, 1);
      await loadCart();
    }, `${product.name} added to cart.`);
  }

  async function changeQuantity(productId, nextQuantity) {
    if (nextQuantity < 1) return;
    await run(async () => {
      await cartApi.update(productId, nextQuantity);
      await loadCart();
    });
  }

  async function removeFromCart(productId) {
    await run(async () => {
      await cartApi.remove(productId);
      await loadCart();
    }, 'Item removed.');
  }

  async function checkout() {
    if (cart.length === 0) {
      setError('Your cart is empty.');
      return;
    }

    await run(async () => {
      await checkoutApi.checkout();
      await Promise.all([loadCart(), loadOrders(), loadProducts({ keyword, category })]);
      setActivePanel('orders');
    }, 'Checkout completed. Your order was recorded.');
  }

  function searchProducts(event) {
    event.preventDefault();
    loadProducts({ keyword: keyword.trim(), category });
  }

  return (
    <div className="app-shell">
      <header className="site-header">
        <div className="brand-block">
          <div className="brand-icon"><ShoppingBag size={24} /></div>
          <div>
            <p className="eyebrow">ShopCloud</p>
            <h1>Modern storefront</h1>
          </div>
        </div>

        <nav className="nav-tabs">
          <button className={activePanel === 'shop' ? 'active' : ''} onClick={() => setActivePanel('shop')}>Shop</button>
          <button className={activePanel === 'cart' ? 'active' : ''} onClick={() => setActivePanel('cart')}>Cart <span>{cart.length}</span></button>
          <button className={activePanel === 'orders' ? 'active' : ''} onClick={() => setActivePanel('orders')}>Orders</button>
          <button className={activePanel === 'account' ? 'active' : ''} onClick={() => setActivePanel('account')}>Account</button>
        </nav>

        <div className="user-pill">
          <UserRound size={17} />
          <span>{user ? user.email : 'Guest'}</span>
          {user && <button className="icon-button" onClick={logout} title="Logout"><LogOut size={16} /></button>}
        </div>
      </header>

      <main>
        <section className="hero-card">
          <div>
            <p className="eyebrow"><Sparkles size={15} /> Cloud-ready e-commerce</p>
            <h2>Browse, cart, checkout, and track orders from one clean customer app.</h2>
            <p className="hero-text">
              This React app talks to auth, catalog, cart, and checkout as separate services through API paths that can later be routed by EKS ingress.
            </p>
            <div className="hero-actions">
              <button className="primary-button" onClick={() => setActivePanel('shop')}>Start shopping <ArrowRight size={18} /></button>
              <button className="secondary-button" onClick={() => setActivePanel('cart')}>View cart</button>
            </div>
          </div>
          <div className="hero-stats">
            <Stat icon={<Package />} label="Products" value={products.length} />
            <Stat icon={<ShoppingCart />} label="Cart lines" value={cart.length} />
            <Stat icon={<Clock3 />} label="Orders" value={orders.length} />
          </div>
        </section>

        {(notice || error) && (
          <div className={`message ${error ? 'error' : 'success'}`}>
            {error || notice}
          </div>
        )}

        {activePanel === 'shop' && (
          <section className="content-grid shop-layout">
            <div className="panel wide-panel">
              <div className="panel-header">
                <div>
                  <p className="eyebrow">Catalog</p>
                  <h3>Available products</h3>
                </div>
                <form className="search-form" onSubmit={searchProducts}>
                  <div className="input-with-icon">
                    <Search size={17} />
                    <input value={keyword} onChange={(e) => setKeyword(e.target.value)} placeholder="Search products" />
                  </div>
                  <select value={category} onChange={(e) => setCategory(e.target.value)}>
                    <option value="">All categories</option>
                    {categories.map((item) => <option key={item} value={item}>{item}</option>)}
                  </select>
                  <button className="dark-button" type="submit">Search</button>
                </form>
              </div>

              {products.length === 0 ? (
                <EmptyState icon={<Boxes />} title="No products yet" text="Use the admin dashboard to add catalog items, then refresh this page." />
              ) : (
                <div className="product-grid">
                  {products.map((product) => (
                    <article className="product-card" key={product.id}>
                      <div className="product-image" style={{ backgroundImage: `url(${product.imageUrl || fallbackImage})` }}>
                        <span>{product.category}</span>
                      </div>
                      <div className="product-body">
                        <div>
                          <h4>{product.name}</h4>
                          <p>{product.description || 'No description provided.'}</p>
                        </div>
                        <div className="product-meta">
                          <strong>{money(product.price)}</strong>
                          <span className={product.stock > 0 ? 'stock in' : 'stock out'}>{product.stock} in stock</span>
                        </div>
                        <button className="primary-button full" disabled={loading || product.stock < 1} onClick={() => addToCart(product)}>
                          Add to cart
                        </button>
                      </div>
                    </article>
                  ))}
                </div>
              )}
            </div>
          </section>
        )}

        {activePanel === 'cart' && (
          <section className="content-grid cart-layout">
            <div className="panel">
              <div className="panel-header">
                <div>
                  <p className="eyebrow">Cart</p>
                  <h3>Your selected items</h3>
                </div>
                <button className="ghost-button" onClick={loadCart}>Refresh</button>
              </div>

              {cartLines.length === 0 ? (
                <EmptyState icon={<ShoppingCart />} title="Your cart is empty" text="Add products from the catalog to start checkout." />
              ) : (
                <div className="cart-list">
                  {cartLines.map((item) => (
                    <div className="cart-line" key={item.id || item.productId}>
                      <div className="small-product-image" style={{ backgroundImage: `url(${item.product?.imageUrl || fallbackImage})` }} />
                      <div className="cart-line-main">
                        <h4>{item.product?.name || `Product #${item.productId}`}</h4>
                        <p>{money(item.product?.price)} each</p>
                      </div>
                      <div className="quantity-control">
                        <button onClick={() => changeQuantity(item.productId, item.quantity - 1)}>-</button>
                        <span>{item.quantity}</span>
                        <button onClick={() => changeQuantity(item.productId, item.quantity + 1)}>+</button>
                      </div>
                      <strong>{money(item.lineTotal)}</strong>
                      <button className="icon-button danger" onClick={() => removeFromCart(item.productId)}><Trash2 size={17} /></button>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <aside className="panel summary-panel">
              <p className="eyebrow">Checkout</p>
              <h3>Order summary</h3>
              <div className="summary-row"><span>Items</span><strong>{cartLines.reduce((sum, item) => sum + item.quantity, 0)}</strong></div>
              <div className="summary-row"><span>Total</span><strong>{money(cartTotal)}</strong></div>
              <button className="primary-button full" onClick={checkout} disabled={loading || cartLines.length === 0}>
                <CreditCard size={18} /> Confirm checkout
              </button>
              <p className="fine-print">Payment is simulated by the backend checkout service.</p>
            </aside>
          </section>
        )}

        {activePanel === 'orders' && (
          <section className="panel">
            <div className="panel-header">
              <div>
                <p className="eyebrow">Orders</p>
                <h3>Order history</h3>
              </div>
              <button className="ghost-button" onClick={loadOrders}>Refresh</button>
            </div>

            {!user ? (
              <EmptyState icon={<ShieldCheck />} title="Login required" text="Log in to view your order history." />
            ) : orders.length === 0 ? (
              <EmptyState icon={<Package />} title="No orders yet" text="Complete checkout to create your first order." />
            ) : (
              <div className="order-grid">
                {orders.map((order) => (
                  <article className="order-card" key={order.id}>
                    <div className="order-card-top">
                      <div>
                        <p className="eyebrow">Order #{order.id}</p>
                        <h4>{money(order.totalAmount)}</h4>
                      </div>
                      <span className="status-pill"><CheckCircle2 size={15} /> {order.status}</span>
                    </div>
                    <p className="muted">{formatDate(order.createdAt)}</p>
                    <div className="mini-lines">
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

        {activePanel === 'account' && (
          <section className="content-grid account-layout">
            <div className="panel auth-panel">
              <p className="eyebrow">Customer account</p>
              <h3>{user ? 'You are signed in' : authMode === 'login' ? 'Login' : 'Create account'}</h3>

              {user ? (
                <div className="signed-in-card">
                  <UserRound size={34} />
                  <div>
                    <h4>{user.email}</h4>
                    <p>{user.name || 'Customer'}</p>
                  </div>
                  <button className="secondary-button" onClick={logout}>Logout</button>
                </div>
              ) : (
                <button className="primary-button full" onClick={submitAuth}>
                  Login with Cognito
                </button>
              )}
            </div>

            <div className="panel info-panel">
              <p className="eyebrow">Service flow</p>
              <h3>How this page talks to your microservices</h3>
              <div className="flow-list">
                <FlowItem number="1" title="Auth" text="Customer logs in through auth-service and receives a JWT." />
                <FlowItem number="2" title="Catalog" text="Products are loaded from catalog-service." />
                <FlowItem number="3" title="Cart" text="Cart changes are sent to cart-service with the customer JWT." />
                <FlowItem number="4" title="Checkout" text="Checkout-service validates cart and stock, then records the order." />
              </div>
            </div>
          </section>
        )}
      </main>
    </div>
  );
}

function Stat({ icon, label, value }) {
  return (
    <div className="stat-card">
      <div>{icon}</div>
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
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

function FlowItem({ number, title, text }) {
  return (
    <div className="flow-item">
      <span>{number}</span>
      <div>
        <h4>{title}</h4>
        <p>{text}</p>
      </div>
    </div>
  );
}

export default App;
