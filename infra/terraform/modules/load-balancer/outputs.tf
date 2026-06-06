output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.this.id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID"
  value       = aws_lb.this.zone_id
}

output "target_group_arns" {
  description = "Map of target group ARNs by service name"
  value = {
    web     = aws_lb_target_group.web.arn
    backend = aws_lb_target_group.backend.arn
    ai      = aws_lb_target_group.ai.arn
  }
}

output "https_listener_arn" {
  description = "HTTPS listener ARN"
  value       = aws_lb_listener.https.arn
}

output "web_security_group_id" {
  description = "Web target group security group ID"
  value       = aws_security_group.web_tg.id
}

output "backend_security_group_id" {
  description = "Backend target group security group ID"
  value       = aws_security_group.backend_tg.id
}

output "ai_security_group_id" {
  description = "AI target group security group ID"
  value       = aws_security_group.ai_tg.id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "access_logs_bucket_id" {
  description = "ALB access logs S3 bucket ID"
  value       = aws_s3_bucket.access_logs.id
}
