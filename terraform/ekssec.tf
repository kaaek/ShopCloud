resource "aws_security_group_rule" "database_from_eks_nodes" {
  type                     = "ingress"
  security_group_id        = aws_security_group.database.id
  source_security_group_id = module.eks.node_security_group_id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Allow EKS worker nodes/pods to reach PostgreSQL"
}

resource "aws_security_group_rule" "redis_from_eks_nodes" {
  type                     = "ingress"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = module.eks.node_security_group_id
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  description              = "Allow EKS worker nodes/pods to reach Redis"
}
