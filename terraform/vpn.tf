locals {
  vpn_enabled = var.enable_vpn && var.vpn_server_certificate_arn != "" && var.vpn_root_certificate_chain_arn != ""
}

resource "aws_security_group" "vpn" {
  count = local.vpn_enabled ? 1 : 0

  name        = "shopcloud-vpn-sg"
  description = "Security group for the AWS Client VPN endpoint"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "shopcloud-vpn-sg"
  }
}

resource "aws_security_group_rule" "vpn_ingress_from_clients" {
  count = local.vpn_enabled ? 1 : 0

  type              = "ingress"
  security_group_id = aws_security_group.vpn[0].id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpn_cidr]
  description       = "Allow VPN clients to reach the endpoint"
}

resource "aws_security_group_rule" "vpn_egress_all" {
  count = local.vpn_enabled ? 1 : 0

  type              = "egress"
  security_group_id = aws_security_group.vpn[0].id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow VPN endpoint traffic to reach the VPC"
}

resource "aws_ec2_client_vpn_endpoint" "shopcloud" {
  count = local.vpn_enabled ? 1 : 0

  description            = "ShopCloud admin VPN"
  server_certificate_arn = var.vpn_server_certificate_arn
  client_cidr_block      = var.vpn_cidr
  split_tunnel           = true
  transport_protocol     = "tcp"
  self_service_portal    = "disabled"
  security_group_ids     = [aws_security_group.vpn[0].id]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.vpn_root_certificate_chain_arn
  }

  connection_log_options {
    enabled = false
  }

  dns_servers = length(var.vpn_dns_servers) > 0 ? var.vpn_dns_servers : null

  tags = {
    Name = "ShopCloud-Client-VPN"
  }
}

resource "aws_ec2_client_vpn_network_association" "private_1" {
  count = local.vpn_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.shopcloud[0].id
  subnet_id              = aws_subnet.private_1.id
}

resource "aws_ec2_client_vpn_network_association" "private_2" {
  count = local.vpn_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.shopcloud[0].id
  subnet_id              = aws_subnet.private_2.id
}

resource "aws_ec2_client_vpn_authorization_rule" "vpc" {
  count = local.vpn_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.shopcloud[0].id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_route" "vpc" {
  for_each = local.vpn_enabled ? {
    private_1 = aws_subnet.private_1.id
    private_2 = aws_subnet.private_2.id
  } : {}

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.shopcloud[0].id
  destination_cidr_block = var.vpc_cidr
  target_vpc_subnet_id   = each.value
  description            = "Route VPN traffic to the ShopCloud VPC"

  depends_on = [aws_ec2_client_vpn_authorization_rule.vpc]
}