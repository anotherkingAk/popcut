terraform {
  backend "s3" {
    bucket         = "popcut-terraform-state"
    key            = "environments/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "popcut-terraform-locks"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.tags
  }
}

provider "random" {}

module "popcut" {
  source = "../../"

  environment             = var.environment
  region                  = var.region
  vpc_cidr                = var.vpc_cidr
  availability_zones      = var.availability_zones
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  database_subnet_cidrs   = var.database_subnet_cidrs
  web_instance_type       = var.web_instance_type
  backend_instance_type   = var.backend_instance_type
  ai_instance_type        = var.ai_instance_type
  database_instance_class = var.database_instance_class
  redis_instance_type     = var.redis_instance_type
  domain_name             = var.domain_name
  certificate_arn         = var.certificate_arn
  web_desired_capacity    = var.web_desired_capacity
  web_max_size            = var.web_max_size
  backend_desired_capacity = var.backend_desired_capacity
  backend_max_size        = var.backend_max_size
  ai_desired_capacity     = var.ai_desired_capacity
  ai_max_size             = var.ai_max_size
  multi_az                = var.multi_az
  redis_num_shards        = var.redis_num_shards
  redis_replicas_per_shard = var.redis_replicas_per_shard
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  enable_flow_logs        = var.enable_flow_logs
  enable_performance_insights = var.enable_performance_insights
  tags                    = var.tags
}
