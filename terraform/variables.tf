
variable "aws_region" { default = "us-west-2" }
variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }

variable "db_master_username" { default = "admin" }
variable "db_master_password" { description = "Sensitive", type = string }
