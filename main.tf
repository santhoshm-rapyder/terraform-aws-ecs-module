# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_cp" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.ecs_capacity_provider.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 1
    base              = 1
  }
}

# ✅ Get the latest ECS-optimized Amazon Linux 2 AMI via SSM
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# Launch Template for ECS Instances
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "ecs-template-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.instance_type
  key_name      = var.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.ebs_volume_size
      volume_type = "gp3"
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security_group_id]
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-instance"
    }
  }
}

# Auto Scaling Group for ECS
resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "${var.cluster_name}-asg"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  target_group_arns         = var.target_group_arns
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300

  # ✅ Required for ECS Capacity Provider with managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecs-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ✅ ECS Capacity Provider linked to ASG
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "${var.cluster_name}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 10
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
