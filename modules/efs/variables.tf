variable "project"            { description = "Project name" }
variable "env"                { description = "Environment" }
variable "vpc_id"             { description = "VPC ID" }
variable "private_subnet_ids" { type = list(string) }
variable "app_sg_id"          { description = "App server security group ID" }
