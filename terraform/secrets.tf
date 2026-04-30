resource "random_password" "jwt_secret" {
  length  = 48
  special = true
}

resource "random_password" "internal_token" {
  length  = 48
  special = true
}

resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "shopcloud/${var.environment}/app-secrets"
  recovery_window_in_days = var.environment == "dev" ? 0 : 7

  tags = {
    Name        = "shopcloud-app-secrets"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id

  secret_string = jsonencode({
    SHOPCLOUD_JWT_SECRET     = random_password.jwt_secret.result
    SHOPCLOUD_INTERNAL_TOKEN = random_password.internal_token.result
  })
}

resource "aws_ssm_parameter" "postgres_url" {
  name  = "/shopcloud/${var.environment}/postgres/url"
  type  = "String"
  value = "jdbc:postgresql://${aws_db_instance.postgres_primary.address}:5432/shopcloud?currentSchema=shopcloud"
}

resource "aws_ssm_parameter" "postgres_secret_arn" {
  name  = "/shopcloud/${var.environment}/postgres/secret-arn"
  type  = "String"
  value = aws_db_instance.postgres_primary.master_user_secret[0].secret_arn
}

resource "aws_ssm_parameter" "redis_endpoint" {
  name  = "/shopcloud/${var.environment}/redis/endpoint"
  type  = "String"
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}

resource "aws_ssm_parameter" "invoice_queue_url" {
  name  = "/shopcloud/${var.environment}/invoice/queue-url"
  type  = "String"
  value = aws_sqs_queue.invoice_queue.url
}

resource "aws_ssm_parameter" "customer_cognito_user_pool_id" {
  name  = "/shopcloud/${var.environment}/cognito/customers/user-pool-id"
  type  = "String"
  value = aws_cognito_user_pool.customers.id
}

resource "aws_ssm_parameter" "customer_cognito_client_id" {
  name  = "/shopcloud/${var.environment}/cognito/customers/client-id"
  type  = "String"
  value = aws_cognito_user_pool_client.customer.id
}

resource "aws_ssm_parameter" "admin_cognito_user_pool_id" {
  name  = "/shopcloud/${var.environment}/cognito/admins/user-pool-id"
  type  = "String"
  value = aws_cognito_user_pool.admins.id
}

resource "aws_ssm_parameter" "admin_cognito_client_id" {
  name  = "/shopcloud/${var.environment}/cognito/admins/client-id"
  type  = "String"
  value = aws_cognito_user_pool_client.admin.id
}
