# ShopCloud Spring Boot Apps

This folder contains 5 independent Spring Boot services:

1. `auth-service`
2. `catalog-service`
3. `cart-service`
4. `checkout-service`
5. `admin-service`

No shared Java module is used. Each service has its own local security classes.

## Security model

- Customer/admin authentication uses JWTs issued by `auth-service`.
- Other services validate the JWT locally using the same `SHOPCLOUD_JWT_SECRET`.
- Service-to-service calls use `X-Internal-Token` with the same `SHOPCLOUD_INTERNAL_TOKEN`.
- In Kubernetes/EKS later, these values should come from Kubernetes Secrets / AWS Secrets Manager, not hardcoded files.

## Local ports

| Service | Local port |
|---|---:|
| auth-service | 8080 |
| catalog-service | 8081 |
| cart-service | 8082 |
| checkout-service | 8083 |
| admin-service | 8084 |

Inside EKS, you can override `SERVER_PORT=8080` for every pod and use Kubernetes service DNS names through environment variables.

## Local database setup

Create these PostgreSQL databases locally:

```sql
CREATE DATABASE shopcloud_auth;
CREATE DATABASE shopcloud_catalog;
CREATE DATABASE shopcloud_cart;
CREATE DATABASE shopcloud_checkout;
```

Default local credentials are:

```text
username: postgres
password: postgres
```

You can override them with:

```bash
POSTGRES_USER=...
POSTGRES_PASSWORD=...
```

## Run order locally

Run each app from its own folder:

```bash
mvn spring-boot:run
```

Recommended order:

1. auth-service
2. catalog-service
3. cart-service
4. checkout-service
5. admin-service

## Important endpoints

### Auth

```http
POST http://localhost:8080/api/auth/register
POST http://localhost:8080/api/auth/login
POST http://localhost:8080/api/auth/admin/register
POST http://localhost:8080/api/auth/admin/login
GET  http://localhost:8080/api/auth/me
```

To create an admin, send header:

```text
X-Admin-Bootstrap-Key: change-me-admin-bootstrap-key
```

### Catalog

```http
GET http://localhost:8081/api/products
GET http://localhost:8081/api/products/{id}
GET http://localhost:8081/api/products/search?keyword=phone
```

### Cart

```http
GET    http://localhost:8082/api/cart
POST   http://localhost:8082/api/cart/items
PUT    http://localhost:8082/api/cart/items/{productId}
DELETE http://localhost:8082/api/cart/items/{productId}
DELETE http://localhost:8082/api/cart/clear
```

### Checkout

```http
POST http://localhost:8083/api/checkout
GET  http://localhost:8083/api/orders/my
GET  http://localhost:8083/api/orders/{id}
```

### Admin

```http
POST   http://localhost:8084/api/admin/products
PUT    http://localhost:8084/api/admin/products/{id}
DELETE http://localhost:8084/api/admin/products/{id}
GET    http://localhost:8084/api/admin/orders
POST   http://localhost:8084/api/admin/orders/{id}/return
```

## Example flow

1. Create admin using auth-service.
2. Login as admin and copy JWT.
3. Use admin-service to create products.
4. Register customer using auth-service.
5. Login as customer and copy JWT.
6. Add products to cart.
7. Checkout.
8. Checkout service reads cart, checks catalog stock, decreases stock, saves order, clears cart, and logs an invoice event.

## Notes

- No Dockerfiles are included.
- No Kubernetes manifests are included.
- No Terraform/IaC is included.
- The invoice publisher is a placeholder logger. Later, replace it with SQS code or keep it as a separate infrastructure phase.
- The admin service is stateless. It protects admin APIs and calls catalog/checkout internal APIs.
