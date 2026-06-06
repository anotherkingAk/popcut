data "aws_caller_identity" "current" {}

locals {
  name_prefix = "popcut-${var.environment}"
}

module "networking" {
  source = "./modules/networking"

  environment         = var.environment
  region              = var.region
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  enable_flow_logs    = var.enable_flow_logs
  tags                = var.tags
}

module "security" {
  source = "./modules/security"

  environment     = var.environment
  region          = var.region
  vpc_id          = module.networking.vpc_id
  alb_arn         = module.load_balancer.alb_arn
  domain_name     = var.domain_name
  db_instance_class = var.database_instance_class
  tags            = var.tags
}

module "database" {
  source = "./modules/database"

  environment               = var.environment
  region                    = var.region
  vpc_id                    = module.networking.vpc_id
  database_subnet_ids       = module.networking.database_subnet_ids
  database_instance_class   = var.database_instance_class
  multi_az                  = var.multi_az
  backup_retention_period   = var.backup_retention_period
  deletion_protection       = var.deletion_protection
  enable_performance_insights = var.enable_performance_insights
  db_credentials_secret_arn = module.security.db_credentials_secret_arn
  kms_key_arn               = module.security.kms_key_arns["rds"]
  tags                      = var.tags
}

module "cache" {
  source = "./modules/cache"

  environment           = var.environment
  region                = var.region
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  redis_instance_type   = var.redis_instance_type
  num_shards            = var.redis_num_shards
  replicas_per_shard    = var.redis_replicas_per_shard
  kms_key_arn           = module.security.kms_key_arns["redis"]
  tags                  = var.tags
}

module "load_balancer" {
  source = "./modules/load-balancer"

  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  certificate_arn   = var.certificate_arn
  domain_name       = var.domain_name
  web_port          = var.web_port
  backend_port      = var.backend_port
  ai_port           = var.ai_port
  deletion_protection = var.deletion_protection
  tags              = var.tags
}

module "compute" {
  source = "./modules/compute"

  environment           = var.environment
  region                = var.region
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.load_balancer.alb_security_group_id
  web_security_group_id = module.load_balancer.web_security_group_id
  backend_security_group_id = module.load_balancer.backend_security_group_id
  ai_security_group_id  = module.load_balancer.ai_security_group_id
  alb_target_group_arns = module.load_balancer.target_group_arns
  web_instance_type     = var.web_instance_type
  backend_instance_type = var.backend_instance_type
  ai_instance_type      = var.ai_instance_type
  web_desired_capacity  = var.web_desired_capacity
  web_max_size          = var.web_max_size
  backend_desired_capacity = var.backend_desired_capacity
  backend_max_size      = var.backend_max_size
  ai_desired_capacity   = var.ai_desired_capacity
  ai_max_size           = var.ai_max_size
  web_port              = var.web_port
  backend_port          = var.backend_port
  ai_port               = var.ai_port
  db_credentials_secret_arn = module.security.db_credentials_secret_arn
  jwt_secret_arn        = module.security.jwt_secret_arn
  tags                  = var.tags
}
