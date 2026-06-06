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
  description = "Private subnet IDs for Redis deployment"
  type        = list(string)
}

variable "redis_instance_type" {
  description = "Redis node type"
  type        = string
}

variable "num_shards" {
  description = "Number of Redis shards"
  type        = number
  default     = 1
}

variable "replicas_per_shard" {
  description = "Number of replicas per shard"
  type        = number
  default     = 0
}

variable "kms_key_arn" {
  description = "KMS key ARN for Redis encryption"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
