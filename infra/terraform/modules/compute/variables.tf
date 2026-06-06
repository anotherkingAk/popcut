variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB security group ID"
  type        = string
}

variable "web_security_group_id" {
  description = "Web target group security group ID"
  type        = string
}

variable "backend_security_group_id" {
  description = "Backend target group security group ID"
  type        = string
}

variable "ai_security_group_id" {
  description = "AI target group security group ID"
  type        = string
}

variable "alb_target_group_arns" {
  description = "Map of ALB target group ARNs"
  type        = map(string)
}

variable "web_instance_type" {
  description = "EC2 instance type for web"
  type        = string
}

variable "backend_instance_type" {
  description = "EC2 instance type for backend"
  type        = string
}

variable "ai_instance_type" {
  description = "EC2 instance type for AI"
  type        = string
}

variable "web_desired_capacity" {
  description = "Desired web instances"
  type        = number
  default     = 2
}

variable "web_max_size" {
  description = "Maximum web instances"
  type        = number
  default     = 6
}

variable "backend_desired_capacity" {
  description = "Desired backend instances"
  type        = number
  default     = 2
}

variable "backend_max_size" {
  description = "Maximum backend instances"
  type        = number
  default     = 6
}

variable "ai_desired_capacity" {
  description = "Desired AI instances"
  type        = number
  default     = 2
}

variable "ai_max_size" {
  description = "Maximum AI instances"
  type        = number
  default     = 6
}

variable "web_port" {
  description = "Web service port"
  type        = number
  default     = 80
}

variable "backend_port" {
  description = "Backend service port"
  type        = number
  default     = 4001
}

variable "ai_port" {
  description = "AI service port"
  type        = number
  default     = 8000
}

variable "db_credentials_secret_arn" {
  description = "ARN of DB credentials secret"
  type        = string
}

variable "jwt_secret_arn" {
  description = "ARN of JWT secret"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
