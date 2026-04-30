variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name. Use separate state/VPCs for dev and prod."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.0.0/24"
}

variable "subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.64.0/24"
}

variable "subnet_3_cidr" {
  description = "CIDR block for private EKS subnet 1"
  type        = string
  default     = "10.0.128.0/24"
}

variable "subnet_4_cidr" {
  description = "CIDR block for private EKS subnet 2"
  type        = string
  default     = "10.0.192.0/24"
}

variable "subnet_5_cidr" {
  description = "CIDR block for isolated DB/cache subnet 1"
  type        = string
  default     = "10.0.96.0/24"
}

variable "subnet_6_cidr" {
  description = "CIDR block for isolated DB/cache subnet 2"
  type        = string
  default     = "10.0.160.0/24"
}

variable "vpn_cidr" {
  description = "Client CIDR block for AWS Client VPN. Must not overlap with the VPC CIDR."
  type        = string
}

variable "eks_api_allowed_cidrs" {
  description = "Public source CIDRs allowed to reach the EKS Kubernetes API endpoint. Use your public IP /32 for real deployments."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_name" {
  description = "Name for the EKS cluster"
  type        = string
  default     = "shopcloud-cluster"
}

variable "root_domain_name" {
  description = "Public Route 53 zone name used for the customer frontend"
  type        = string
}

variable "customer_record_name" {
  description = "Relative Route 53 name for the customer frontend"
  type        = string
  default     = "www"
}

variable "cloudfront_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for the CloudFront aliases"
  type        = string
}

variable "customer_ingress_domain_name" {
  description = "Public DNS name of the customer ALB/Ingress. Fill this after the Kubernetes public ingress exists."
  type        = string
}

variable "cloudfront_price_class" {
  description = "CloudFront price class for the customer distribution"
  type        = string
  default     = "PriceClass_100"
}

variable "waf_name" {
  description = "Name for the CloudFront web ACL"
  type        = string
  default     = "shopcloud-cloudfront-waf"
}

variable "cognito_domain_prefix" {
  description = "Base Cognito hosted UI domain prefix. Terraform appends -customers and -admins."
  type        = string
}

variable "cognito_customer_callback_urls" {
  description = "Allowed Cognito callback URLs for the customer app"
  type        = list(string)
}

variable "cognito_customer_logout_urls" {
  description = "Allowed Cognito logout URLs for the customer app"
  type        = list(string)
}

variable "cognito_admin_callback_urls" {
  description = "Allowed Cognito callback URLs for the admin app"
  type        = list(string)
}

variable "cognito_admin_logout_urls" {
  description = "Allowed Cognito logout URLs for the admin app"
  type        = list(string)
}

variable "vpn_server_certificate_arn" {
  description = "ACM server certificate ARN for the AWS Client VPN endpoint"
  type        = string
}

variable "vpn_root_certificate_chain_arn" {
  description = "ACM root certificate chain ARN for AWS Client VPN certificate authentication"
  type        = string
}

variable "vpn_dns_servers" {
  description = "Optional DNS servers pushed to VPN clients"
  type        = list(string)
  default     = []
}

variable "ses_sender_email" {
  description = "Verified SES sender email address"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for stateful resources in production. Keep false for demo/dev so terraform destroy works."
  type        = bool
  default     = false
}
