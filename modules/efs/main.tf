# ─────────────────────────────────────────────────────────────────────────────
# Module: EFS (Elastic File System)
# Project: AspTax (Incresol Software Services)
# Creates: EFS, Mount Targets, Security Group
# Use case: Shared file storage across multiple EC2 instances
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_security_group" "efs" {
  name        = "${var.project}-${var.env}-efs-sg"
  description = "Allow NFS from app servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from app servers"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-${var.env}-efs-sg" }
}

resource "aws_efs_file_system" "main" {
  creation_token   = "${var.project}-${var.env}-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  tags = {
    Name        = "${var.project}-${var.env}-efs"
    Environment = var.env
    Project     = var.project
  }
}

# Mount targets in each private subnet
resource "aws_efs_mount_target" "main" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}
