variable "aws_region" {
    description = "AWS region to deploy resources"
    type = string
    default = "us-east-1"
}
variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
    type = string
    default = "10.0.0.0/20"
}

variable "public_subnet_2_cidr" {
    type = string
    default = "10.0.16.0/20"
}

variable "private_subnet_cidr" {
    type = string
    default = "10.0.32.0/20"
}

variable "cluster_name" {
    description = "Name for the EKS cluster"
    type = string
    default = "ShopCloud-cluster"
}


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