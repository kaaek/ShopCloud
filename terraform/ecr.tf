locals {
  ecr_repositories = [
    "auth-service",
    "admin-service",
    "catalog-service",
    "cart-service",
    "checkout-service",
    "customer-frontend",
    "admin-frontend"
  ]
}

resource "aws_ecr_repository" "services" {
  for_each = toset(local.ecr_repositories)

  name = "shopcloud/${each.key}"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}