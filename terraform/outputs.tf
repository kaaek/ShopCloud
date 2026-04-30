output "route53_zone_id" {
  description = "Hosted zone ID for the ShopCloud public domain"
  value       = aws_route53_zone.shopcloud.zone_id
}

output "customer_frontend_url" {
  description = "Primary URL for the customer storefront"
  value       = "https://${local.root_domain_name}"
}

output "admin_frontend_url" {
  description = "URL for the admin dashboard"
  value       = "https://${local.frontend_sites.admin.domain_name}"
}

output "cognito_user_pool_id" {
  description = "Cognito user pool ID"
  value       = aws_cognito_user_pool.shopcloud.id
}

output "cognito_customer_client_id" {
  description = "Cognito app client ID for the customer frontend"
  value       = aws_cognito_user_pool_client.customer.id
}

output "cognito_admin_client_id" {
  description = "Cognito app client ID for the admin frontend"
  value       = aws_cognito_user_pool_client.admin.id
}

output "cognito_hosted_ui_domain" {
  description = "Cognito hosted UI domain prefix"
  value       = aws_cognito_user_pool_domain.shopcloud.domain
}

output "vpn_endpoint_id" {
  description = "AWS Client VPN endpoint ID"
  value       = aws_ec2_client_vpn_endpoint.shopcloud.id
}

output "cloudfront_domains" {
  description = "CloudFront distribution domain names"
  value = {
    for site_name, distribution in aws_cloudfront_distribution.frontend : site_name => distribution.domain_name
  }
}

output "waf_web_acl_arn" {
  description = "CloudFront WAF web ACL ARN"
  value       = aws_wafv2_web_acl.cloudfront.arn
}

output "vpn_endpoint_id" {
  description = "AWS Client VPN endpoint ID for private admin access"
  value       = aws_ec2_client_vpn_endpoint.shopcloud.id
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_node_security_group_id" {
  description = "EKS node security group ID"
  value       = module.eks.node_security_group_id
}

output "customer_cognito_user_pool_id" {
  description = "Customer Cognito user pool ID"
  value       = aws_cognito_user_pool.customers.id
}

output "customer_cognito_client_id" {
  description = "Customer Cognito app client ID"
  value       = aws_cognito_user_pool_client.customer.id
}

output "admin_cognito_user_pool_id" {
  description = "Admin Cognito user pool ID"
  value       = aws_cognito_user_pool.admins.id
}

output "admin_cognito_client_id" {
  description = "Admin Cognito app client ID"
  value       = aws_cognito_user_pool_client.admin.id
}

output "customer_cognito_hosted_ui_domain" {
  description = "Customer Cognito hosted UI domain prefix"
  value       = aws_cognito_user_pool_domain.customers.domain
}

output "admin_cognito_hosted_ui_domain" {
  description = "Admin Cognito hosted UI domain prefix"
  value       = aws_cognito_user_pool_domain.admins.domain
}

output "postgres_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres_primary.address
}

output "postgres_secret_arn" {
  description = "Secrets Manager ARN for the RDS managed master secret"
  value       = aws_db_instance.postgres_primary.master_user_secret[0].secret_arn
  sensitive   = true
}

output "redis_primary_endpoint" {
  description = "ElastiCache Redis primary endpoint"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "invoice_queue_url" {
  description = "URL for the invoice SQS queue"
  value       = aws_sqs_queue.invoice_queue.url
}

output "invoice_queue_arn" {
  description = "ARN for the invoice SQS queue"
  value       = aws_sqs_queue.invoice_queue.arn
}

output "invoice_bucket_name" {
  description = "Name of the invoice S3 bucket"
  value       = aws_s3_bucket.invoice_bucket.bucket
}

output "product_images_bucket_name" {
  description = "Name of the product images S3 bucket"
  value       = aws_s3_bucket.product_images_bucket.bucket
}

output "ecr_repository_urls" {
  description = "Map of ECR repository names to their URLs"
  value = {
    for name, repo in aws_ecr_repository.services : name => repo.repository_url
  }
}

output "pod_irsa_role_arns" {
  description = "IRSA role ARNs to annotate Kubernetes service accounts"
  value = {
    for name, role in aws_iam_role.pod_irsa : name => role.arn
  }
}
