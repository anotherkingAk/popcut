output "web_asg_id" {
  description = "Web auto scaling group ID"
  value       = aws_autoscaling_group.web.id
}

output "web_asg_name" {
  description = "Web auto scaling group name"
  value       = aws_autoscaling_group.web.name
}

output "backend_asg_id" {
  description = "Backend auto scaling group ID"
  value       = aws_autoscaling_group.backend.id
}

output "backend_asg_name" {
  description = "Backend auto scaling group name"
  value       = aws_autoscaling_group.backend.name
}

output "ai_asg_id" {
  description = "AI auto scaling group ID"
  value       = aws_autoscaling_group.ai.id
}

output "ai_asg_name" {
  description = "AI auto scaling group name"
  value       = aws_autoscaling_group.ai.name
}

output "web_launch_template_id" {
  description = "Web launch template ID"
  value       = aws_launch_template.web.id
}

output "backend_launch_template_id" {
  description = "Backend launch template ID"
  value       = aws_launch_template.backend.id
}

output "ai_launch_template_id" {
  description = "AI launch template ID"
  value       = aws_launch_template.ai.id
}
