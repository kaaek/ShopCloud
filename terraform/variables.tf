# —————— Region —————— #
variable "aws_region" {
    description = "AWS region to deploy resources"
    type = string
    default = "us-east-1"
}
# —————— CIDRs —————— #
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_1_cidr" {
  description = "CIDR block for subnet 1"
  type = string
  default = "10.0.0.0/18"
}

variable "subnet_2_cidr" {
  description = "CIDR block for subnet 2"
  type = string
  default = "10.0.64.0/18"
}

variable "subnet_3_cidr" {
  description = "CIDR block for subnet 3"
  type = string
  default = "10.0.128.0/18"
}

variable "subnet_4_cidr" {
  description = "CIDR block for subnet 4"
  type = string
  default = "10.0.192.0/18"
}

variable "subnet_5_cidr" {
  description = "CIDR block for subnet 5"
  type = string
  default = "10.0.96.0/18"
}

variable "subnet_6_cidr" {
  description = "CIDR block for subnet 6"
  type = string
  default = "10.0.160.0/18"
}

variable "eks_api_allowed_cidrs" {
  description = "CIDR blocks allowed to access the EKS cluster API"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpn_cidr" {
  description = "CIDR block for the VPN network allowed to reach the admin entrypoint"
  type = string
}
# —————— EKS —————— #
variable "cluster_name" {
    description = "Name for the EKS cluster"
    type = string
    default = "ShopCloud-cluster"
}
# —————— Compute —————— #
data "aws_ami" "amazon-linux-2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

  # —————— Edge / Identity / Access —————— #

  variable "customer_ingress_domain_name" {
    description = "Public DNS name of the customer ingress controller or ALB"
    type = string
  }

  variable "admin_ingress_domain_name" {
    description = "Public DNS name of the admin ingress controller or ALB"
    type = string
  }

  variable "shared_ingress_domain_name" {
    description = "If set, CloudFront will use this shared ingress domain for all frontends (overrides per-site ingress names)"
    type = string
    default = ""
  }

  variable "cloudfront_price_class" {
    description = "CloudFront price class for the frontend distributions"
    type = string
    default = "PriceClass_100"
  }

  variable "waf_name" {
    description = "Name for the CloudFront web ACL"
    type = string
    default = "shopcloud-cloudfront-waf"
  }

  variable "cognito_domain_prefix" {
    description = "Cognito hosted UI domain prefix"
    type = string
  }

  variable "cognito_customer_callback_urls" {
    description = "Allowed Cognito callback URLs for the customer app"
    type = list(string)
  }

  variable "cognito_customer_logout_urls" {
    description = "Allowed Cognito logout URLs for the customer app"
    type = list(string)
  }

  variable "cognito_admin_callback_urls" {
    description = "Allowed Cognito callback URLs for the admin app"
    type = list(string)
  }

  variable "cognito_admin_logout_urls" {
    description = "Allowed Cognito logout URLs for the admin app"
    type = list(string)
  }

  variable "vpn_server_certificate_arn" {
    description = "ACM server certificate ARN for the AWS Client VPN endpoint"
    type = string
  }

  variable "vpn_root_certificate_chain_arn" {
    description = "ACM root certificate chain ARN for AWS Client VPN certificate authentication"
    type = string
  }

  variable "vpn_dns_servers" {
    description = "Optional DNS servers pushed to VPN clients"
    type = list(string)
    default = []
  }

  variable "environment" {
    description = "Environment name (dev, staging, prod)"
    type = string
    default = "dev"
  }

  variable "enable_deletion_protection" {
    description = "Enable deletion protection for critical resources"
    type = bool
    default = false
  }

  variable "ses_sender_email" {
    description = "SES verified sender email address for invoice notifications"
    type = string
  }

  variable "enable_cross_region_replica" {
    description = "Enable cross-region read replica for RDS"
    type = bool
    default = true
  }

  variable "alb_certificate_arn" {
    description = "ACM certificate ARN for the public ALB (customer frontend)"
    type = string
    default = ""
  }

variable "enable_public_edge" {
  description = "Enable public edge (CloudFront + WAF) for internet-facing traffic"
  type        = bool
  default     = true  # or false, depending on your setup
}

variable "enable_vpn" {
  description = "Enable VPN endpoint"
  type        = bool
  default     = false  # or true, depending on your setup
}