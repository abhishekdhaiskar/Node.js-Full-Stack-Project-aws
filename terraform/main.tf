
provider "aws" {
  region = var.aws_region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"
  cluster_name    = "fullstack-eks"
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  node_groups = {
    main = {
      desired_capacity = 2
      instance_type    = "t3.medium"
    }
  }
}

resource "aws_db_subnet_group" "dbsubnet" {
  name       = "fullstack-db-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "postgres" {
  identifier         = "fullstack-db"
  engine             = "postgres"
  instance_class     = "db.t3.micro"
  username           = var.db_master_username
  password           = var.db_master_password
  allocated_storage  = 20
  db_subnet_group_name = aws_db_subnet_group.dbsubnet.name
  skip_final_snapshot   = true
}
