variable "aws_region" {
  default = "us-west-2"
}

variable "db_master_username" {
  default = "dbmaster"  # avoid 'admin'
}

variable "db_master_password" {
  description = "RDS DB master password"
  type        = string
  sensitive   = true
}
