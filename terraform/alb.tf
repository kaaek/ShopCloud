# ————————— Internal Admin ALB ————————— #
# ALB for admin frontend accessed via VPN (no public internet)
resource "aws_lb" "admin_internal" {
  name               = "shopcloud-admin-alb-${var.environment}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.admin.id]
  subnets            = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = true
  enable_cross_zone_load_balancing = true

  tags = {
    Name        = "shopcloud-admin-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "admin_frontend" {
  name        = "shopcloud-admin-frontend-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name        = "shopcloud-admin-frontend-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "admin_http" {
  load_balancer_arn = aws_lb.admin_internal.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.admin_frontend.arn
  }
}

# ————————— Public Customer ALB ————————— #
# ALB for customer frontend (routes traffic from CloudFront)
resource "aws_lb" "customer_public" {
  name               = "shopcloud-customer-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.customer_ingress.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = true
  enable_cross_zone_load_balancing = true

  tags = {
    Name        = "shopcloud-customer-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "customer_frontend" {
  name        = "shopcloud-customer-frontend-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name        = "shopcloud-customer-frontend-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "customer_http" {
  load_balancer_arn = aws_lb.customer_public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.customer_frontend.arn
  }
}

resource "aws_lb_listener" "customer_https" {
  load_balancer_arn = aws_lb.customer_public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.customer_frontend.arn
  }
}
