variable "project"            { description = "Project name" }
variable "env"                { description = "Environment" }
variable "vpc_id"             { description = "VPC ID" }
variable "alb_sg_id"          { description = "ALB security group ID" }
variable "private_subnet_ids" { type = list(string) }
variable "target_group_arns"  { type = list(string); default = [] }
variable "ami_id"             { description = "Amazon Machine Image ID" }
variable "instance_type"      { default = "t3.medium" }
variable "key_name"           { description = "EC2 key pair name" }
variable "app_port"           { default = 3000 }
variable "admin_cidr"         { description = "CIDR allowed for SSH" }
variable "root_volume_size"   { default = 20 }
variable "asg_min"            { default = 1 }
variable "asg_max"            { default = 3 }
variable "asg_desired"        { default = 2 }
