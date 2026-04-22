# ShopCloud Admin Service

Minimal internal admin microservice for managing products, stock levels, and returns.

## What it does
- Create, list, update, and delete products
- Increase and decrease stock
- Process returns by increasing stock only
- Protect `/api/admin/**` with JWT role `ADMIN`
- Intended to sit behind a private entry point only

## Why it matches your architecture
Your project says the admin path must stay off the public internet and should only be reachable through AWS Client VPN and an Internal ALB, with a separate ingress for the admin service. It also lists `admin` as its own microservice in EKS. fileciteturn1file0

This code handles the application side of that requirement. The network isolation itself must still be enforced in AWS and Kubernetes.

## Endpoints
- `POST /api/admin/products`
- `GET /api/admin/products`
- `GET /api/admin/products/{id}`
- `PUT /api/admin/products/{id}`
- `POST /api/admin/products/{id}/stock/increase`
- `POST /api/admin/products/{id}/stock/decrease`
- `POST /api/admin/products/{id}/returns`
- `DELETE /api/admin/products/{id}`

## Example requests
### Create product
```http
POST /api/admin/products
Content-Type: application/json
Authorization: Bearer <admin-jwt>

{
  "sku": "SKU-1001",
  "name": "Gaming Mouse",
  "description": "Wireless gaming mouse",
  "price": 49.99,
  "stock": 20,
  "active": true
}
```

### Increase stock
```http
POST /api/admin/products/1/stock/increase
Content-Type: application/json
Authorization: Bearer <admin-jwt>

{
  "amount": 5
}
```

### Process return
```http
POST /api/admin/products/1/returns
Content-Type: application/json
Authorization: Bearer <admin-jwt>

{
  "amount": 2
}
```

## Notes for deployment
- Put this service behind your **internal ingress** only.
- Do not expose it through the public ALB or CloudFront.
- Point `issuer-uri` to the **admin Cognito user pool**.
- Replace the local Postgres connection with your RDS endpoint or service DNS.
- For production, prefer `ddl-auto=validate` or migrations with Flyway/Liquibase.
