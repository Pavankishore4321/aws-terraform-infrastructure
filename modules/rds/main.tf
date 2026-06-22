# ─────────────────────────────────────────────────────────────────────────────
# Module: RDS (Relational Database Service)
# Project: AspTax, Spring Boot multi-client deployments (Incresol)
# Creates: RDS Instance, DB Subnet Group, Security Group
# Supports: MySQL and PostgreSQL
# ─────────────────────────────────────────────────────────────────────────────

# ── DB SECURITY GROUP ─────────────────────────────────────────────────────────
resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.env}-rds-sg"
  description = "Allow DB access from app servers only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "DB access from app servers"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-${var.env}-rds-sg" }
}

# ── DB SUBNET GROUP ───────────────────────────────────────────────────────────
resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-${var.env}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = { Name = "${var.project}-${var.env}-db-subnet-group" }
}

# ── RDS INSTANCE ──────────────────────────────────────────────────────────────
resource "aws_db_instance" "main" {
  identifier        = "${var.project}-${var.env}-db"
  engine            = var.db_engine            # "mysql" or "postgres"
  engine_version    = var.db_engine_version    # "8.0" or "14.6"
  instance_class    = var.db_instance_class    # "db.t3.micro"
  allocated_storage = var.db_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # High availability — Multi-AZ for production
  multi_az = var.env == "prod" ? true : false

  # Automated backups
  backup_retention_period = var.env == "prod" ? 7 : 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Prevent accidental deletion in prod
  deletion_protection = var.env == "prod" ? true : false
  skip_final_snapshot = var.env == "prod" ? false : true

  final_snapshot_identifier = var.env == "prod" ? "${var.project}-${var.env}-final-snapshot" : null

  tags = {
    Name        = "${var.project}-${var.env}-rds"
    Environment = var.env
    Project     = var.project
  }
}
