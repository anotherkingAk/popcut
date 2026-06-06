locals {
  name_prefix = "popcut-${var.environment}"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

data "aws_region" "current" {}

locals {
  user_data_base = templatefile("${path.module}/user_data.sh.tpl", {
    environment               = var.environment
    region                    = var.region
    db_credentials_secret_arn = var.db_credentials_secret_arn
    jwt_secret_arn            = var.jwt_secret_arn
  })
}

resource "aws_launch_template" "web" {
  name_prefix   = "${local.name_prefix}-web-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.web_instance_type

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      var.web_security_group_id,
    ]
  }

  user_data = base64encode(local.user_data_base)

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name  = "${local.name_prefix}-web"
      Role  = "web"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${local.name_prefix}-web-volume"
    })
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-web-lt"
  })
}

resource "aws_launch_template" "backend" {
  name_prefix   = "${local.name_prefix}-backend-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.backend_instance_type

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 50
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      var.backend_security_group_id,
    ]
  }

  user_data = base64encode(local.user_data_base)

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name  = "${local.name_prefix}-backend"
      Role  = "backend"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${local.name_prefix}-backend-volume"
    })
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-backend-lt"
  })
}

resource "aws_launch_template" "ai" {
  name_prefix   = "${local.name_prefix}-ai-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.ai_instance_type

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 100
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      var.ai_security_group_id,
    ]
  }

  user_data = base64encode(local.user_data_base)

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name  = "${local.name_prefix}-ai"
      Role  = "ai"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${local.name_prefix}-ai-volume"
    })
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-ai-lt"
  })
}

resource "aws_autoscaling_group" "web" {
  name                = "${local.name_prefix}-web-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = 1
  max_size            = var.web_max_size
  desired_capacity    = var.web_desired_capacity

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [
    var.alb_target_group_arns["web"],
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-web-asg"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_group" "backend" {
  name                = "${local.name_prefix}-backend-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = 1
  max_size            = var.backend_max_size
  desired_capacity    = var.backend_desired_capacity

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  target_group_arns = [
    var.alb_target_group_arns["backend"],
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-backend-asg"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_group" "ai" {
  name                = "${local.name_prefix}-ai-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = 1
  max_size            = var.ai_max_size
  desired_capacity    = var.ai_desired_capacity

  launch_template {
    id      = aws_launch_template.ai.id
    version = "$Latest"
  }

  target_group_arns = [
    var.alb_target_group_arns["ai"],
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-ai-asg"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "web_cpu" {
  name                   = "${local.name_prefix}-web-cpu-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_autoscaling_policy" "web_cpu_in" {
  name                   = "${local.name_prefix}-web-cpu-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_high" {
  alarm_name          = "${local.name_prefix}-web-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Web service CPU > 70%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_actions = [aws_autoscaling_policy.web_cpu.arn]
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_low" {
  alarm_name          = "${local.name_prefix}-web-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Web service CPU < 30%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_actions = [aws_autoscaling_policy.web_cpu_in.arn]
}

resource "aws_autoscaling_policy" "backend_cpu" {
  name                   = "${local.name_prefix}-backend-cpu-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.backend.name
}

resource "aws_autoscaling_policy" "backend_cpu_in" {
  name                   = "${local.name_prefix}-backend-cpu-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.backend.name
}

resource "aws_cloudwatch_metric_alarm" "backend_cpu_high" {
  alarm_name          = "${local.name_prefix}-backend-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Backend service CPU > 70%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.backend.name
  }

  alarm_actions = [aws_autoscaling_policy.backend_cpu.arn]
}

resource "aws_cloudwatch_metric_alarm" "backend_cpu_low" {
  alarm_name          = "${local.name_prefix}-backend-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Backend service CPU < 30%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.backend.name
  }

  alarm_actions = [aws_autoscaling_policy.backend_cpu_in.arn]
}

resource "aws_autoscaling_policy" "ai_cpu" {
  name                   = "${local.name_prefix}-ai-cpu-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ai.name
}

resource "aws_autoscaling_policy" "ai_cpu_in" {
  name                   = "${local.name_prefix}-ai-cpu-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ai.name
}

resource "aws_cloudwatch_metric_alarm" "ai_cpu_high" {
  alarm_name          = "${local.name_prefix}-ai-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "AI service CPU > 70%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ai.name
  }

  alarm_actions = [aws_autoscaling_policy.ai_cpu.arn]
}

resource "aws_cloudwatch_metric_alarm" "ai_cpu_low" {
  alarm_name          = "${local.name_prefix}-ai-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "AI service CPU < 30%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ai.name
  }

  alarm_actions = [aws_autoscaling_policy.ai_cpu_in.arn]
}

resource "aws_iam_instance_profile" "this" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_instance.name

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-ec2-profile"
  })
}

resource "aws_iam_role" "ec2_instance" {
  name = "${local.name_prefix}-asg-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-asg-ec2-role"
  })
}

resource "aws_iam_role_policy" "ec2_secrets" {
  name = "${local.name_prefix}-asg-secrets-access"
  role = aws_iam_role.ec2_instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ]
        Resource = [
          var.db_credentials_secret_arn,
          var.jwt_secret_arn,
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_ssm_params" {
  name = "${local.name_prefix}-asg-ssm-access"
  role = aws_iam_role.ec2_instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
        ]
        Resource = ["arn:aws:ssm:${var.region}:*:parameter/popcut/${var.environment}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_cw_agent" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
