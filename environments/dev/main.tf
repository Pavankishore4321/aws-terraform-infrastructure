# ─────────────────────────────────────────────────────────────────────────────
# Environment: DEV
# Project: AspTax (Incresol Software Services)
# Calls all modules to provision complete dev infrastructure
# ─────────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Store state in S3 (uncomment after creating the bucket manually)
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "asptax/dev/terraform.tfstate"
  #   region = "ap-south-1"
  # }
}

provider "aws" {
  region = var.aws_region
}

# ── VPC ───────────────────────────────────────────────────────────────────────
module "vpc" {
  source = "../../modules/vpc"

  project               = var.project
  env                   = var.env
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  availability_zones    = var.availability_zones
}

# ── ALB ───────────────────────────────────────────────────────────────────────
module "alb" {
  source = "../../modules/alb"

  project           = var.project
  env               = var.env
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  app_port          = var.app_port
  health_check_path = "/health"
}

# ── EC2 (Auto Scaling) ────────────────────────────────────────────────────────
module "ec2" {
  source = "../../modules/ec2"

  project            = var.project
  env                = var.env
  vpc_id             = module.vpc.vpc_id
  alb_sg_id          = module.alb.alb_sg_id
  private_subnet_ids = module.vpc.private_subnet_ids
  target_group_arns  = [module.alb.target_group_arn]
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  app_port           = var.app_port
  admin_cidr         = var.admin_cidr
  asg_min            = 1
  asg_max            = 2
  asg_desired        = 1
}

# ── RDS ───────────────────────────────────────────────────────────────────────
module "rds" {
  source = "../../modules/rds"

  project            = var.project
  env                = var.env
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  app_sg_id          = module.ec2.app_sg_id
  db_engine          = var.db_engine
  db_engine_version  = var.db_engine_version
  db_instance_class  = "db.t3.micro"
  db_storage         = 20
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
}

# ── EFS ───────────────────────────────────────────────────────────────────────
module "efs" {
  source = "../../modules/efs"

  project            = var.project
  env                = var.env
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  app_sg_id          = module.ec2.app_sg_id
}

# ── S3 ────────────────────────────────────────────────────────────────────────
module "s3" {
  source = "../../modules/s3"

  project       = var.project
  env           = var.env
  bucket_suffix = "assets"
}
