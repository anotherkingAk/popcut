output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Database subnet IDs"
  value       = module.networking.database_subnet_ids
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.load_balancer.alb_dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID"
  value       = module.load_balancer.alb_zone_id
}

output "rds_endpoint" {
  description = "RDS primary endpoint"
  value       = module.database.rds_endpoint
  sensitive   = true
}

output "rds_reader_endpoint" {
  description = "RDS reader endpoint"
  value       = module.database.rds_reader_endpoint
  sensitive   = true
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint"
  value       = module.cache.redis_primary_endpoint
  sensitive   = true
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint"
  value       = module.cache.redis_reader_endpoint
  sensitive   = true
}

output "web_asg_id" {
  description = "Web auto scaling group ID"
  value       = module.compute.web_asg_id
}

output "backend_asg_id" {
  description = "Backend auto scaling group ID"
  value       = module.compute.backend_asg_id
}

output "ai_asg_id" {
  description = "AI auto scaling group ID"
  value       = module.compute.ai_asg_id
}

output "web_security_group_id" {
  description = "Web security group ID"
  value       = module.load_balancer.web_security_group_id
}

output "backend_security_group_id" {
  description = "Backend security group ID"
  value       = module.load_balancer.backend_security_group_id
}

output "ai_security_group_id" {
  description = "AI security group ID"
  value       = module.load_balancer.ai_security_group_id
}

output "database_security_group_id" {
  description = "Database security group ID"
  value       = module.database.security_group_id
}

output "redis_security_group_id" {
  description = "Redis security group ID"
  value       = module.cache.security_group_id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.load_balancer.alb_security_group_id
}

output "db_credentials_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = module.security.db_credentials_secret_arn
  sensitive   = true
}

output "jwt_secret_arn" {
  description = "ARN of the JWT secret"
  value       = module.security.jwt_secret_arn
  sensitive   = true
}

output "kms_key_arns" {
  description = "KMS key ARNs"
  value       = module.security.kms_key_arns
  sensitive   = true
}
