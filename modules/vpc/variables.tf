variable "project"              { description = "Project name" }
variable "env"                  { description = "Environment (dev/prod)" }
variable "vpc_cidr"             { description = "VPC CIDR block" }
variable "public_subnet_cidrs"  { type = list(string); description = "Public subnet CIDRs" }
variable "private_subnet_cidrs" { type = list(string); description = "Private subnet CIDRs" }
variable "availability_zones"   { type = list(string); description = "AZs to use" }
