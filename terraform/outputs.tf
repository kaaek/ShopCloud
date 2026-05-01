# ————————— Route 53 & DNS ————————— #
output "route53_zone_id" {
  description = "Hosted zone ID for the ShopCloud public domain"
  value       = var.enable_public_edge ? aws_route53_zone.shopcloud[0].zone_id : null
}

output "customer_frontend_url" {
  description = "Primary URL for the customer storefront"
  value       = var.enable_public_edge ? "https://${local.root_domain_name}" : "http://${aws_lb.customer_public.dns_name}"
}

output "admin_frontend_url" {
  description = "URL for the admin dashboard"
  value       = var.enable_public_edge ? "https://${local.frontend_sites.admin.domain_name}" : "http://${aws_lb.admin_internal.dns_name}"
}

# ————————— CloudFront & WAF ————————— #
output "cloudfront_domains" {
  description = "CloudFront distribution domain names"
  value = var.enable_public_edge ? {
    for site_name, distribution in aws_cloudfront_distribution.frontend : site_name => distribution.domain_name
  } : {}
}

output "waf_web_acl_arn" {
  description = "CloudFront WAF web ACL ARN"
  value       = var.enable_public_edge ? aws_wafv2_web_acl.cloudfront[0].arn : null
}

# ————————— Load Balancers ————————— #
output "customer_alb_dns_name" {
  description = "DNS name of the customer-facing public ALB"
  value       = aws_lb.customer_public.dns_name
}

output "customer_alb_arn" {
  description = "ARN of the customer-facing public ALB"
  value       = aws_lb.customer_public.arn
}

output "admin_alb_dns_name" {
  description = "DNS name of the internal admin ALB (accessible via VPN)"
  value       = aws_lb.admin_internal.dns_name
}

output "admin_alb_arn" {
  description = "ARN of the internal admin ALB"
  value       = aws_lb.admin_internal.arn
}

# ————————— Cognito ————————— #
output "customer_cognito_user_pool_id" {
  description = "Customer Cognito user pool ID"
  value       = aws_cognito_user_pool.customers.id
}

output "customer_cognito_client_id" {
  description = "Customer Cognito app client ID"
  value       = aws_cognito_user_pool_client.customer.id
}

output "customer_cognito_hosted_ui_domain" {
  description = "Customer Cognito hosted UI domain prefix"
  value       = aws_cognito_user_pool_domain.customers.domain
}

output "admin_cognito_user_pool_id" {
  description = "Admin Cognito user pool ID"
  value       = aws_cognito_user_pool.admins.id
}

output "admin_cognito_client_id" {
  description = "Admin Cognito app client ID"
  value       = aws_cognito_user_pool_client.admin.id
}

output "admin_cognito_hosted_ui_domain" {
  description = "Admin Cognito hosted UI domain prefix"
  value       = aws_cognito_user_pool_domain.admins.domain
}

# ————————— VPN ————————— #
output "vpn_endpoint_id" {
  description = "AWS Client VPN endpoint ID for private admin access"
  value       = var.enable_vpn ? aws_ec2_client_vpn_endpoint.shopcloud[0].id : null
}

# ————————— EKS ————————— #
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_node_security_group_id" {
  description = "EKS node security group ID"
  value       = module.eks.node_security_group_id
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN for IRSA"
  value       = module.eks.oidc_provider_arn
}

# ————————— Database ————————— #
output "postgres_endpoint" {
  description = "RDS PostgreSQL primary endpoint"
  value       = aws_db_instance.postgres_primary.address
}

output "postgres_secret_arn" {
  description = "Secrets Manager ARN for the RDS managed master secret"
  value       = aws_db_instance.postgres_primary.master_user_secret[0].secret_arn
  sensitive   = true
}

output "postgres_replica_endpoint" {
  description = "RDS PostgreSQL cross-region read replica endpoint"
  value       = var.enable_cross_region_replica ? aws_db_instance.postgres_replica[0].address : null
}

# ————————— Cache ————————— #
output "redis_primary_endpoint" {
  description = "ElastiCache Redis primary endpoint"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "ElastiCache Redis reader endpoint for scaling read operations"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

# ————————— Messaging ————————— #
output "invoice_queue_url" {
  description = "URL for the invoice SQS queue"
  value       = aws_sqs_queue.invoice_queue.url
}

output "invoice_queue_arn" {
  description = "ARN for the invoice SQS queue"
  value       = aws_sqs_queue.invoice_queue.arn
}

# ————————— Storage ————————— #
output "invoice_bucket_name" {
  description = "Name of the invoice S3 bucket"
  value       = aws_s3_bucket.invoice_bucket.bucket
}

output "product_images_bucket_name" {
  description = "Name of the product images S3 bucket"
  value       = aws_s3_bucket.product_images_bucket.bucket
}

# ————————— Container Registry ————————— #
output "ecr_repository_urls" {
  description = "Map of ECR repository names to their URLs"
  value = {
    for name, repo in aws_ecr_repository.services : name => repo.repository_url
  }
}

# ————————— Identity & Access ————————— #
output "pod_irsa_role_arns" {
  description = "IRSA role ARNs to annotate Kubernetes service accounts"
  value = {
    for name, role in aws_iam_role.pod_irsa : name => role.arn
  }
}

# ————————— Encryption ————————— #
output "kms_key_id" {
  description = "KMS key ID for application encryption"
  value       = aws_kms_key.shopcloud.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN for application encryption"
  value       = aws_kms_key.shopcloud.arn
}

output "secrets_manager_kms_key_id" {
  description = "KMS key ID for Secrets Manager encryption"
  value       = aws_kms_key.secrets_manager.key_id
}

output "secrets_manager_kms_key_arn" {
  description = "KMS key ARN for Secrets Manager encryption"
  value       = aws_kms_key.secrets_manager.arn
}
