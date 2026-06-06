output "db_credentials_secret_arn" {
  description = "ARN of the DB credentials secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "jwt_secret_arn" {
  description = "ARN of the JWT secret"
  value       = aws_secretsmanager_secret.jwt_secret.arn
}

output "api_key_secret_arn" {
  description = "ARN of the API key secret"
  value       = aws_secretsmanager_secret.api_key.arn
}

output "kms_key_arns" {
  description = "Map of KMS key ARNs by purpose"
  value = {
    ebs   = aws_kms_key.ebs.arn
    rds   = aws_kms_key.rds.arn
    s3    = aws_kms_key.s3.arn
    redis = aws_kms_key.redis.arn
  }
}

output "kms_key_ids" {
  description = "Map of KMS key IDs by purpose"
  value = {
    ebs   = aws_kms_key.ebs.key_id
    rds   = aws_kms_key.rds.key_id
    s3    = aws_kms_key.s3.key_id
    redis = aws_kms_key.redis.key_id
  }
}

output "ec2_instance_role_arn" {
  description = "EC2 instance IAM role ARN"
  value       = aws_iam_role.ec2_instance.arn
}

output "ec2_instance_role_name" {
  description = "EC2 instance IAM role name"
  value       = aws_iam_role.ec2_instance.name
}

output "rds_monitoring_role_arn" {
  description = "RDS monitoring IAM role ARN"
  value       = aws_iam_role.rds_monitoring.arn
}

output "admin_role_arn" {
  description = "Admin IAM role ARN"
  value       = aws_iam_role.admin.arn
}

output "waf_web_acl_id" {
  description = "WAF web ACL ID"
  value       = aws_wafv2_web_acl.this.id
}

output "waf_web_acl_arn" {
  description = "WAF web ACL ARN"
  value       = aws_wafv2_web_acl.this.arn
}
