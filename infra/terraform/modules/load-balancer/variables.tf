variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
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

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
