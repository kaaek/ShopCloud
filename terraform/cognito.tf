resource "aws_cognito_user_pool" "shopcloud" {
  name = "shopcloud-user-pool"

  username_attributes     = ["email"]
  auto_verified_attributes = ["email"]
  mfa_configuration      = "OFF"
  deletion_protection    = "ACTIVE"

  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  schema {
    name                = "email"
    attribute_data_type  = "String"
    required             = true
    mutable              = true

    string_attribute_constraints {
      min_length = 5
      max_length = 2048
    }
  }
}

resource "aws_cognito_user_group" "customer" {
  user_pool_id = aws_cognito_user_pool.shopcloud.id
  name         = "customers"
  description  = "Customer storefront users"
  precedence   = 10
}

resource "aws_cognito_user_group" "admin" {
  user_pool_id = aws_cognito_user_pool.shopcloud.id
  name         = "admins"
  description  = "Administrative users"
  precedence   = 1
}

resource "aws_cognito_user_pool_domain" "shopcloud" {
  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.shopcloud.id
}

resource "aws_cognito_user_pool_client" "customer" {
  name                                = "shopcloud-customer-client"
  user_pool_id                        = aws_cognito_user_pool.shopcloud.id
  generate_secret                     = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                 = ["code"]
  allowed_oauth_scopes                = ["openid", "email", "profile", "aws.cognito.signin.user.admin"]
  supported_identity_providers        = ["COGNITO"]
  callback_urls                       = var.cognito_customer_callback_urls
  logout_urls                         = var.cognito_customer_logout_urls
  explicit_auth_flows                 = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
  prevent_user_existence_errors       = "ENABLED"
}

resource "aws_cognito_user_pool_client" "admin" {
  name                                = "shopcloud-admin-client"
  user_pool_id                        = aws_cognito_user_pool.shopcloud.id
  generate_secret                     = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                 = ["code"]
  allowed_oauth_scopes                = ["openid", "email", "profile", "aws.cognito.signin.user.admin"]
  supported_identity_providers        = ["COGNITO"]
  callback_urls                       = var.cognito_admin_callback_urls
  logout_urls                         = var.cognito_admin_logout_urls
  explicit_auth_flows                 = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
  prevent_user_existence_errors       = "ENABLED"
}