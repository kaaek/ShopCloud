module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id = aws_vpc.main.id
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.eks_api_allowed_cidrs
  cluster_endpoint_private_access      = true

  enable_irsa = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Allow EKS worker nodes to communicate with each other"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    egress_all = {
      description = "Allow EKS worker nodes to reach AWS services through NAT/VPC endpoints"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                          = "AL2023_x86_64_STANDARD"
    instance_types                    = ["t3.small"]
    attach_cluster_primary_security_group = true
    disk_size                         = 20
  }

  eks_managed_node_groups = {
    shopcloud = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      capacity_type  = "ON_DEMAND"
      instance_types = ["t3.small"]

      labels = {
        workload = "shopcloud"
      }

      iam_role_additional_policies = {
        ecr_readonly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }

      tags = {
        Name        = "ShopCloud-EKS-Managed-Node-Group"
        Environment = var.environment
      }
    }
  }
}
