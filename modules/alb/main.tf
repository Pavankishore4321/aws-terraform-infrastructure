# ─────────────────────────────────────────────────────────────────────────────
# Module: Application Load Balancer (ALB)
# Project: AspTax (Incresol Software Services)
# Creates: ALB, ALB Security Group, Target Group, HTTP/HTTPS Listeners
# ─────────────────────────────────────────────────────────────────────────────

# ── ALB SECURITY GROUP ────────────────────────────────────────────────────────
resource "aws_security_group" "alb" {
  name        = "${var.project}-${var.env}-alb-sg"
  description = "Allow HTTP/HTTPS to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-${var.env}-alb-sg" }
}

# ── APPLICATION LOAD BALANCER ─────────────────────────────────────────────────
resource "aws_lb" "main" {
  name               = "${var.project}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.env == "prod" ? true : false

  tags = {
    Name        = "${var.project}-${var.env}-alb"
    Environment = var.env
    Project     = var.project
  }
}

# ── TARGET GROUP ──────────────────────────────────────────────────────────────
resource "aws_lb_target_group" "app" {
  name     = "${var.project}-${var.env}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = { Name = "${var.project}-${var.env}-tg" }
}

# ── HTTP LISTENER (redirect to HTTPS) ────────────────────────────────────────
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ── HTTPS LISTENER ────────────────────────────────────────────────────────────
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
