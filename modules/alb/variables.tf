variable "project"           { description = "Project name" }
variable "env"               { description = "Environment" }
variable "vpc_id"            { description = "VPC ID" }
variable "public_subnet_ids" { type = list(string) }
variable "app_port"          { default = 3000 }
variable "health_check_path" { default = "/health" }
variable "certificate_arn"   { default = "" }
