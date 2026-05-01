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

enable_public_edge = true
enable_vpn         = true

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

customer_ingress_domain_name = "customer-public-alb.us-east-1.elb.amazonaws.com"

admin_ingress_domain_name = "admin-internal-alb.us-east-1.elb.amazonaws.com"

vpn_root_certificate_chain_arn = ""

vpn_server_certificate_arn = ""