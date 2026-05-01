# ShopCloud React Frontends

This folder contains **two separate React/Vite apps**:

| App | Folder | Purpose | Default dev port |
|---|---|---|---|
| Customer storefront | `customer-frontend` | Product browsing, customer login/register, cart, checkout, order history | `5173` |
| Admin dashboard | `admin-frontend` | Admin login/register, product management, order/return management | `5174` |

There is intentionally **no shared frontend package** between the two apps. Each app has its own API client, styles, configuration, and components.

## Backend ports expected locally

These match the Spring Boot services generated earlier:

| Service | Local port |
|---|---:|
| auth-service | `8080` |
| catalog-service | `8081` |
| cart-service | `8082` |
| checkout-service | `8083` |
| admin-service | `8084` |

## Run the customer app

```bash
cd customer-frontend
npm install
npm run dev
```

Open:

```text
http://localhost:5173
```

## Run the admin app

```bash
cd admin-frontend
npm install
npm run dev
```

Open:

```text
http://localhost:5174
```

## Why the frontend uses relative URLs

The React code calls URLs like:

```text
/api/products
/api/cart
/api/checkout
/api/admin/products
```

In local development, `vite.config.js` proxies each path to the correct Spring Boot service.

Later in EKS, you can use ingress path routing, for example:

```text
/api/auth/**      -> auth-service
/api/products/**  -> catalog-service
/api/cart/**      -> cart-service
/api/checkout/**  -> checkout-service
/api/orders/**    -> checkout-service
/api/admin/**     -> admin-service
```

That means the React code does not need to know pod IPs or machine IPs.

## Admin bootstrap key

Admin registration calls:

```text
POST /api/auth/admin/register
Header: X-Admin-Bootstrap-Key
```

For local development, set this in `admin-frontend/.env`:

```bash
VITE_ADMIN_BOOTSTRAP_KEY=change-me-admin-bootstrap-key
```

This must match `SHOPCLOUD_ADMIN_BOOTSTRAP_KEY` in the backend auth-service.

## Important CORS note

The Vite proxy avoids CORS problems during local development. In production/EKS, put the frontend and backend APIs behind the same domain using ingress/path routing, or configure CORS explicitly in Spring Boot.
