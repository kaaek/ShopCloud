resource "aws_elasticache_subnet_group" "shopcloud" {
  name = "shopcloud-redis-subnet-group-${var.environment}"

  subnet_ids = [
    aws_subnet.db_1.id,
    aws_subnet.db_2.id
  ]
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "shopcloud-redis-${var.environment}"
  description          = "Redis for ShopCloud cart and session state"

  engine    = "redis"
  node_type = "cache.t4g.micro"
  port      = 6379

  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true

  subnet_group_name  = aws_elasticache_subnet_group.shopcloud.name
  security_group_ids = [aws_security_group.redis.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = {
    Name        = "shopcloud-redis"
    Environment = var.environment
  }
}
