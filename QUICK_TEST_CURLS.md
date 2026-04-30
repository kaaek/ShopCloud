# Quick test with cURL

Run the services first. Then use these commands.

## 1. Register admin

```bash
curl -X POST http://localhost:8080/api/auth/admin/register \
  -H "Content-Type: application/json" \
  -H "X-Admin-Bootstrap-Key: change-me-admin-bootstrap-key" \
  -d '{"fullName":"Admin User","email":"admin@shopcloud.com","password":"password123"}'
```

## 2. Login admin

```bash
curl -X POST http://localhost:8080/api/auth/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@shopcloud.com","password":"password123"}'
```

Copy the token into `ADMIN_TOKEN`.

```bash
ADMIN_TOKEN="paste-token-here"
```

## 3. Create product through admin service

```bash
curl -X POST http://localhost:8084/api/admin/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{"name":"Laptop","description":"Simple laptop","category":"Electronics","imageUrl":"https://example.com/laptop.png","price":999.99,"stock":10}'
```

## 4. Register customer

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Customer User","email":"customer@shopcloud.com","password":"password123"}'
```

## 5. Login customer

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"customer@shopcloud.com","password":"password123"}'
```

Copy the token into `CUSTOMER_TOKEN`.

```bash
CUSTOMER_TOKEN="paste-token-here"
```

## 6. List products

```bash
curl http://localhost:8081/api/products
```

## 7. Add product to cart

Use the product id returned above.

```bash
curl -X POST http://localhost:8082/api/cart/items \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CUSTOMER_TOKEN" \
  -d '{"productId":1,"quantity":2}'
```

## 8. Checkout

```bash
curl -X POST http://localhost:8083/api/checkout \
  -H "Authorization: Bearer $CUSTOMER_TOKEN"
```

## 9. Admin list orders

```bash
curl http://localhost:8084/api/admin/orders \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```
