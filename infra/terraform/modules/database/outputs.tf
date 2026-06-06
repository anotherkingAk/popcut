output "rds_endpoint" {
  description = "RDS primary endpoint"
  value       = aws_db_instance.this.endpoint
}

output "rds_reader_endpoint" {
  description = "RDS reader endpoint (same as primary if not Multi-AZ)"
  value       = aws_db_instance.this.endpoint
}

output "rds_arn" {
  description = "RDS ARN"
  value       = aws_db_instance.this.arn
}

output "rds_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.id
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.this.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.this.db_name
}

output "security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

output "parameter_group_id" {
  description = "RDS parameter group ID"
  value       = aws_db_parameter_group.this.id
}

output "subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.this.name
}

output "cloudwatch_alarm_arns" {
  description = "CloudWatch alarm ARNs"
  value = [
    aws_cloudwatch_metric_alarm.connections,
    aws_cloudwatch_metric_alarm.cpu,
    aws_cloudwatch_metric_alarm.storage,
  ]
}
