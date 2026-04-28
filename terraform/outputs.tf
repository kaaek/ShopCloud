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