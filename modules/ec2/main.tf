# ─────────────────────────────────────────────────────────────────────────────
# Module: EC2
# Project: AspTax (Incresol Software Services)
# Creates: EC2 instances, Security Group, Key Pair, Auto Scaling Group
# ─────────────────────────────────────────────────────────────────────────────

# ── SECURITY GROUP ────────────────────────────────────────────────────────────
resource "aws_security_group" "app" {
  name        = "${var.project}-${var.env}-app-sg"
  description = "Security group for ${var.project} application servers"
  vpc_id      = var.vpc_id

  # Allow HTTP from ALB only
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  # Allow HTTPS from ALB only
  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  # Allow app port from ALB
  ingress {
    description     = "App port from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  # Allow SSH from bastion/VPN only
  ingress {
    description = "SSH from admin CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.env}-app-sg"
    Environment = var.env
  }
}

# ── LAUNCH TEMPLATE (for Auto Scaling) ───────────────────────────────────────
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project}-${var.env}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.app.id]

  # EBS root volume
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  # IAM instance profile (for CloudWatch, S3 access)
  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  # User data — install Docker, Nginx on boot
  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    apt update -y
    apt install -y docker.io nginx awscli
    systemctl start docker nginx
    systemctl enable docker nginx
  USERDATA
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project}-${var.env}-app-server"
      Environment = var.env
      Project     = var.project
    }
  }
}

# ── AUTO SCALING GROUP ────────────────────────────────────────────────────────
resource "aws_autoscaling_group" "app" {
  name                = "${var.project}-${var.env}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = var.target_group_arns
  min_size            = var.asg_min
  max_size            = var.asg_max
  desired_capacity    = var.asg_desired
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.env}-app-server"
    propagate_at_launch = true
  }
}

# ── IAM ROLE FOR EC2 (CloudWatch + S3 access) ─────────────────────────────────
resource "aws_iam_role" "app" {
  name = "${var.project}-${var.env}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project}-${var.env}-ec2-profile"
  role = aws_iam_role.app.name
}
