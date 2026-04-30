aws_region   = "us-east-1"
environment  = "dev"
cluster_name = "shopcloud-dev"

vpc_cidr = "10.0.0.0/16"

subnet_1_cidr = "10.0.0.0/20"
subnet_2_cidr = "10.0.16.0/20"
subnet_3_cidr = "10.0.32.0/20"
subnet_4_cidr = "10.0.48.0/20"
subnet_5_cidr = "10.0.64.0/20"
subnet_6_cidr = "10.0.80.0/20"

cognito_domain_prefix = "shopcloud-karim-503q-dev"

cognito_customer_callback_urls = [
  "http://localhost:3000/callback"
]

cognito_customer_logout_urls = [
  "http://localhost:3000"
]

cognito_admin_callback_urls = [
  "http://localhost:3001/callback"
]

cognito_admin_logout_urls = [
  "http://localhost:3001"
]

ses_sender_email = "your-email@example.com"

vpn_cidr = "10.100.0.0/22"

root_domain_name = "www.shopcloud.com"

customer_ingress_domain_name = "placeholder.example.com"

cloudfront_certificate_arn = "arn:aws:acm:us-east-1:091470428184:certificate/2dd1452d-855f-4f6e-91f7-3b0bb50da747"

vpn_root_certificate_chain_arn = "arn:aws:acm:us-east-1:123456789012:certificate/placeholder-root"

vpn_server_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/placeholder-server"