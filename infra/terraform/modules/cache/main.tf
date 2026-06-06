locals {
  name_prefix = "popcut-${var.environment}"
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${local.name_prefix}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-redis-subnet-group"
  })
}

resource "aws_elasticache_parameter_group" "this" {
  name        = "${local.name_prefix}-redis-params"
  family      = "redis7"
  description = "Custom parameter group for PopCut ${var.environment}"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }

  parameter {
    name  = "activerehashing"
    value = "yes"
  }

  parameter {
    name  = "timeout"
    value = "300"
  }

  parameter {
    name  = "tcp-keepalive"
    value = "300"
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-redis-params"
  })
}

resource "aws_security_group" "redis" {
  name        = "${local.name_prefix}-redis-sg"
  description = "Redis security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from private subnets"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/8"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-redis-sg"
  })
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = "${local.name_prefix}-redis"
  description                   = "Redis cluster for PopCut ${var.environment}"
  node_type                     = var.redis_instance_type
  num_cache_clusters            = var.num_shards * (1 + var.replicas_per_shard)
  port                          = 6379
  engine                        = "redis"
  engine_version                = "7.1"
  parameter_group_name          = aws_elasticache_parameter_group.this.name
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  security_group_ids            = [aws_security_group.redis.id]

  automatic_failover_enabled    = var.num_shards > 1 || var.replicas_per_shard > 0
  multi_az_enabled              = var.num_shards > 1 || var.replicas_per_shard > 0

  cluster_mode {
    replicas_per_node_group = var.replicas_per_shard
    num_node_groups         = var.num_shards
  }

  at_rest_encryption_enabled   = true
  transit_encryption_enabled   = true
  kms_key_id                   = var.kms_key_arn

  maintenance_window           = "sun:05:00-sun:06:00"
  snapshot_window              = "04:00-05:00"
  snapshot_retention_limit     = 7
  auto_minor_version_upgrade   = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-redis"
  })

  lifecycle {
    prevent_destroy = true
  }
}
