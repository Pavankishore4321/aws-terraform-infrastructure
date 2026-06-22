variable "project"            { description = "Project name" }
variable "env"                { description = "Environment" }
variable "vpc_id"             { description = "VPC ID" }
variable "private_subnet_ids" { type = list(string) }
variable "app_sg_id"          { description = "App server security group ID" }
variable "db_engine"          { default = "mysql" }
variable "db_engine_version"  { default = "8.0" }
variable "db_instance_class"  { default = "db.t3.micro" }
variable "db_storage"         { default = 20 }
variable "db_name"            { description = "Database name" }
variable "db_username"        { description = "Master username" }
variable "db_password"        { description = "Master password"; sensitive = true }
variable "db_port"            { default = 3306 }
