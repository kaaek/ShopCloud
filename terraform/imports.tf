import {
  to = aws_kms_alias.shopcloud
  id = "alias/shopcloud-dev"
}

import {
  to = aws_kms_alias.secrets_manager
  id = "alias/shopcloud-secrets-dev"
}

import {
  to = module.eks.module.kms.aws_kms_alias.this["cluster"]
  id = "alias/eks/shopcloud-dev"
}

import {
  to = aws_lambda_function.invoice_pdf_lambda
  id = "shopcloud-invoice-pdf-generator-dev"
}

import {
  to = aws_elasticache_subnet_group.shopcloud
  id = "shopcloud-redis-subnet-group-dev"
}

import {
  to = aws_s3_bucket.product_images_bucket
  id = "shopcloud-product-images-dev-909487697971"
}

import {
  to = aws_ssm_parameter.invoice_queue_url
  id = "/shopcloud/dev/invoice/queue-url"
}

import {
  to = aws_ssm_parameter.customer_cognito_user_pool_id
  id = "/shopcloud/dev/cognito/customers/user-pool-id"
}

import {
  to = aws_ssm_parameter.customer_cognito_client_id
  id = "/shopcloud/dev/cognito/customers/client-id"
}

import {
  to = aws_ssm_parameter.admin_cognito_user_pool_id
  id = "/shopcloud/dev/cognito/admins/user-pool-id"
}

import {
  to = aws_ssm_parameter.admin_cognito_client_id
  id = "/shopcloud/dev/cognito/admins/client-id"
}

import {
  to = aws_lambda_event_source_mapping.sqs_to_lambda
  id = "1fbc6f7e-710f-4a42-a711-d3c6d1dd7978"
}

import {
  to = aws_ssm_parameter.redis_endpoint
  id = "/shopcloud/dev/redis/endpoint"
}

import {
  to = aws_ssm_parameter.postgres_url
  id = "/shopcloud/dev/postgres/url"
}

import {
  to = aws_ssm_parameter.postgres_secret_arn
  id = "/shopcloud/dev/postgres/secret-arn"
}