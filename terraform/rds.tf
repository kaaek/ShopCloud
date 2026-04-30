resource "aws_db_subnet_group" "shopcloud" {
  name = "shopcloud-db-subnet-group-${var.environment}"

  subnet_ids = [
    aws_subnet.db_1.id,
    aws_subnet.db_2.id
  ]

  tags = {
    Name        = "shopcloud-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_instance" "postgres_primary" {
  identifier = "shopcloud-postgres-${var.environment}"

  engine         = "postgres"
  instance_class = "db.t4g.micro"

  db_name  = "shopcloud"
  username = "shopcloud_admin"

  allocated_storage = 20
  storage_type      = "gp3"

  manage_master_user_password = true

  multi_az               = true
  publicly_accessible    = false
  storage_encrypted      = true
  deletion_protection    = var.enable_deletion_protection
  backup_retention_period = 7
  skip_final_snapshot    = true

  db_subnet_group_name   = aws_db_subnet_group.shopcloud.name
  vpc_security_group_ids = [aws_security_group.database.id]

  tags = {
    Name        = "shopcloud-postgres-primary"
    Environment = var.environment
  }
}
