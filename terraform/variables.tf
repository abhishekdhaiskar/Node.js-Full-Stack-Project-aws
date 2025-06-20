variable "aws_region" {
  default = "us-west-2"
}

variable "db_master_username" {
  default = "admin"
}

variable "db_master_password" {
  description = "RDS DB master password"
  type        = string
  sensitive   = true
}
