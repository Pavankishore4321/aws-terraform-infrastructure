# ─────────────────────────────────────────────────────────────────────────────
# Prod Environment Variables — AspTax
# Production uses larger instances, Multi-AZ RDS, more ASG capacity
# ─────────────────────────────────────────────────────────────────────────────

project    = "asptax"
env        = "prod"
aws_region = "ap-south-1"

vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
availability_zones   = ["ap-south-1a", "ap-south-1b"]

ami_id        = "ami-0f58b397bc5c1f2e8"
instance_type = "t3.medium"           # Larger than dev
key_name      = "asptax-prod-key"
app_port      = 3000
admin_cidr    = "10.0.0.0/8"         # Restricted to internal only

db_engine         = "mysql"
db_engine_version = "8.0"
db_name           = "asptax_prod"
db_username       = "asptax_admin"
db_password       = "CHANGE_ME_BEFORE_USE"
