variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
}

variable "web_instance_type" {
  description = "EC2 instance type for web service"
  type        = string
  default     = "t3.medium"
}

variable "backend_instance_type" {
  description = "EC2 instance type for backend service"
  type        = string
  default     = "t3.medium"
}

variable "ai_instance_type" {
  description = "EC2 instance type for AI service"
  type        = string
  default     = "t3.medium"
}

variable "database_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "redis_instance_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t3.medium"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

variable "web_port" {
  description = "Web service port"
  type        = number
  default     = 80
}

variable "backend_port" {
  description = "Backend API port"
  type        = number
  default     = 4001
}

variable "ai_port" {
  description = "AI service port"
  type        = number
  default     = 8000
}

variable "web_desired_capacity" {
  description = "Desired number of web instances"
  type        = number
  default     = 2
}

variable "web_max_size" {
  description = "Maximum number of web instances"
  type        = number
  default     = 6
}

variable "backend_desired_capacity" {
  description = "Desired number of backend instances"
  type        = number
  default     = 2
}

variable "backend_max_size" {
  description = "Maximum number of backend instances"
  type        = number
  default     = 6
}

variable "ai_desired_capacity" {
  description = "Desired number of AI instances"
  type        = number
  default     = 2
}

variable "ai_max_size" {
  description = "Maximum number of AI instances"
  type        = number
  default     = 6
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "redis_num_shards" {
  description = "Number of Redis shards"
  type        = number
  default     = 1
}

variable "redis_replicas_per_shard" {
  description = "Number of Redis replicas per shard"
  type        = number
  default     = 0
}

variable "backup_retention_period" {
  description = "Database backup retention period in days"
  type        = number
  default     = 35
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "enable_performance_insights" {
  description = "Enable RDS Performance Insights"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project   = "PopCut"
    ManagedBy = "Terraform"
  }
}
