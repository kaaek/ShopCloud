resource "aws_security_group" "customer_ingress" {
  name        = "shopcloud-customer-ingress-sg"
  description = "Internet-facing ingress controller for the customer storefront"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "shopcloud-customer-ingress-sg"
  }
}

resource "aws_security_group_rule" "customer_ingress_http" {
  type              = "ingress"
  security_group_id = aws_security_group.customer_ingress.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "customer_ingress_https" {
  type              = "ingress"
  security_group_id = aws_security_group.customer_ingress.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "frontend" {
  name        = "shopcloud-frontend-sg"
  description = "Customer frontend workloads behind the public ingress controller"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "shopcloud-frontend-sg"
  }
}

resource "aws_security_group_rule" "frontend_from_customer_ingress" {
  type                     = "ingress"
  security_group_id        = aws_security_group.frontend.id
  source_security_group_id = aws_security_group.customer_ingress.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  description              = "Allow the customer ingress controller to reach the frontend"
}

resource "aws_security_group_rule" "frontend_to_backend_customer" {
  type                     = "egress"
  security_group_id        = aws_security_group.frontend.id
  source_security_group_id = aws_security_group.backend.id
  from_port                = 8080
  to_port                  = 8083
  protocol                 = "tcp"
  description              = "Allow the customer frontend to proxy API traffic to backend services"
}

resource "aws_security_group" "admin" {
  name        = "shopcloud-admin-sg"
  description = "Admin frontend entrypoint restricted to the VPN CIDR"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "shopcloud-admin-sg"
  }
}

resource "aws_security_group_rule" "admin_from_vpn_http" {
  type              = "ingress"
  security_group_id = aws_security_group.admin.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.vpn_cidr]
}

resource "aws_security_group_rule" "admin_from_vpn_https" {
  type              = "ingress"
  security_group_id = aws_security_group.admin.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpn_cidr]
}

resource "aws_security_group_rule" "admin_to_backend_auth" {
  type                     = "egress"
  security_group_id        = aws_security_group.admin.id
  source_security_group_id = aws_security_group.backend.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  description              = "Allow admin frontend to reach auth-service"
}

resource "aws_security_group_rule" "admin_to_backend_admin" {
  type                     = "egress"
  security_group_id        = aws_security_group.admin.id
  source_security_group_id = aws_security_group.backend.id
  from_port                = 8084
  to_port                  = 8084
  protocol                 = "tcp"
  description              = "Allow admin frontend to reach admin-service"
}

resource "aws_security_group" "backend" {
  name        = "shopcloud-backend-sg"
  description = "Backend microservices shared by the API layer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "shopcloud-backend-sg"
  }
}

resource "aws_security_group_rule" "backend_from_frontend" {
  type                     = "ingress"
  security_group_id        = aws_security_group.backend.id
  source_security_group_id = aws_security_group.frontend.id
  from_port                = 8080
  to_port                  = 8083
  protocol                 = "tcp"
  description              = "Allow the customer frontend to reach backend services"
}

resource "aws_security_group_rule" "backend_from_admin" {
  type                     = "ingress"
  security_group_id        = aws_security_group.backend.id
  source_security_group_id = aws_security_group.admin.id
  from_port                = 8080
  to_port                  = 8084
  protocol                 = "tcp"
  description              = "Allow the admin frontend to reach auth and admin services"
}

resource "aws_security_group_rule" "backend_self_ingress" {
  type                     = "ingress"
  security_group_id        = aws_security_group.backend.id
  source_security_group_id = aws_security_group.backend.id
  from_port                = 8080
  to_port                  = 8084
  protocol                 = "tcp"
  description              = "Allow backend services to communicate with each other"
}

resource "aws_security_group_rule" "backend_to_database" {
  type                     = "egress"
  security_group_id        = aws_security_group.backend.id
  source_security_group_id = aws_security_group.database.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Allow backend services to reach PostgreSQL"
}

resource "aws_security_group_rule" "backend_to_redis" {
  type                     = "egress"
  security_group_id        = aws_security_group.backend.id
  source_security_group_id = aws_security_group.redis.id
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  description              = "Allow backend services to reach Redis"
}

resource "aws_security_group" "database" {
  name        = "shopcloud-database-sg"
  description = "RDS PostgreSQL access for backend services"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "shopcloud-database-sg"
  }
}

resource "aws_security_group_rule" "database_from_backend" {
  type                     = "ingress"
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.backend.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Allow backend services to reach PostgreSQL"
}

resource "aws_security_group" "redis" {
  name        = "shopcloud-redis-sg"
  description = "Redis access for backend services"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "shopcloud-redis-sg"
  }
}

resource "aws_security_group_rule" "redis_from_backend" {
  type                     = "ingress"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = aws_security_group.backend.id
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  description              = "Allow backend services to reach Redis"
}