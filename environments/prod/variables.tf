variable "project"              {}
variable "env"                  {}
variable "aws_region"           {}
variable "vpc_cidr"             {}
variable "public_subnet_cidrs"  { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "availability_zones"   { type = list(string) }
variable "ami_id"               {}
variable "instance_type"        {}
variable "key_name"             {}
variable "app_port"             { default = 3000 }
variable "admin_cidr"           {}
variable "db_engine"            {}
variable "db_engine_version"    {}
variable "db_name"              {}
variable "db_username"          {}
variable "db_password"          { sensitive = true }
