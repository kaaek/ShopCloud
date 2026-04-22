# ShopCloud Cart Microservice

Minimal Spring Boot cart service for ShopCloud. It stores carts in Redis / ElastiCache using Spring Data Redis repositories.

## What it does

- Creates a cart session automatically when the browser has no cart cookie.
- Stores cart data in Redis under the `carts` keyspace.
- Persists cart items across page loads using the `SHOPCLOUD_CART_SESSION` cookie.
- Refreshes cart TTL whenever the cart is read or modified.
- Supports adding, updating, removing, clearing, and deleting cart data.

## Main endpoints

```http
GET    /api/cart
POST   /api/cart/items
PUT    /api/cart/items/{productId}
DELETE /api/cart/items/{productId}
DELETE /api/cart/items
DELETE /api/cart
```

## Example add item request

```json
{
  "productId": 1,
  "productName": "Smart Watch",
  "unitPrice": 99.99,
  "quantity": 2,
  "productImageUrl": "https://example.com/watch.png"
}
```

## Environment variables

```bash
SERVER_PORT=8082
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_SSL_ENABLED=false
CART_TTL_DAYS=30
CART_COOKIE_NAME=SHOPCLOUD_CART_SESSION
CART_COOKIE_SECURE=false
CART_COOKIE_MAX_AGE_DAYS=30
```

For ElastiCache in production, set `REDIS_HOST` to the ElastiCache primary endpoint and set `REDIS_SSL_ENABLED=true` if in-transit encryption is enabled.
