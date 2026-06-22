# ─────────────────────────────────────────────────────────────────────────────
# Dev Environment Variables — AspTax
# Replace values as needed for your AWS account
# ─────────────────────────────────────────────────────────────────────────────

# General
project    = "asptax"
env        = "dev"
aws_region = "ap-south-1"   # Mumbai region

# Network
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
availability_zones   = ["ap-south-1a", "ap-south-1b"]

# EC2
ami_id        = "ami-0f58b397bc5c1f2e8"   # Ubuntu 22.04 LTS - Mumbai
instance_type = "t3.small"
key_name      = "asptax-dev-key"
app_port      = 3000
admin_cidr    = "0.0.0.0/0"               # Restrict to your IP in production

# RDS
db_engine         = "mysql"
db_engine_version = "8.0"
db_name           = "asptax_dev"
db_username       = "asptax_admin"
db_password       = "CHANGE_ME_BEFORE_USE"  # Use AWS Secrets Manager in prod
