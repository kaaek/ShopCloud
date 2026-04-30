# ————————— KMS Encryption Keys ————————— #
# KMS key for general application encryption
resource "aws_kms_key" "shopcloud" {
  description             = "KMS key for ShopCloud application encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "shopcloud-kms-key"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "shopcloud" {
  name          = "alias/shopcloud-${var.environment}"
  target_key_id = aws_kms_key.shopcloud.key_id
}

# KMS key for Secrets Manager encryption
resource "aws_kms_key" "secrets_manager" {
  description             = "KMS key for ShopCloud Secrets Manager"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "shopcloud-secrets-kms-key"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "secrets_manager" {
  name          = "alias/shopcloud-secrets-${var.environment}"
  target_key_id = aws_kms_key.secrets_manager.key_id
}
