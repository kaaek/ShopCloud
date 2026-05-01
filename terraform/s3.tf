resource "aws_s3_bucket" "invoice_bucket" {
  bucket        = "shopcloud-invoices-${var.environment}-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.environment == "dev" ? true : false

  tags = {
    Name        = "shopcloud-invoice-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "invoice_bucket" {
  bucket                  = aws_s3_bucket.invoice_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "invoice_bucket" {
  bucket = aws_s3_bucket.invoice_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "product_images_bucket" {
  bucket        = "shopcloud-product-images-${var.environment}-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.environment == "dev" ? true : false

  tags = {
    Name        = "shopcloud-product-images-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "product_images_bucket" {
  bucket                  = aws_s3_bucket.product_images_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "product_images_bucket" {
  bucket = aws_s3_bucket.product_images_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
