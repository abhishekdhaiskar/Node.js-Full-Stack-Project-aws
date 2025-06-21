terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.35.0"  # Compatible with Terraform AWS provider v5
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────────
# VPC with Public and Private Subnets
# ─────────────────────────────────────────────
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "fullstack-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true   # Required for EKS node groups in public subnets
}

# ─────────────────────────────────────────────
# Security Group for RDS
# ─────────────────────────────────────────────
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow DB access from anywhere (not secure for prod)"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 🔒 In production, restrict this!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ─────────────────────────────────────────────
# EKS Cluster and Node Group
# ─────────────────────────────────────────────
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"

  cluster_name = "fullstack-eks"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.public_subnets

  eks_managed_node_groups = {
    main = {
      desired_capacity       = 2
      min_size               = 1
      max_size               = 3
      instance_type          = "t3.medium"
      disk_size              = 20
      ami_type               = "AL2_x86_64"
      capacity_type          = "ON_DEMAND"
      create_launch_template = true
      enable_monitoring      = true
    }
  }

  enable_irsa = true
}

# ─────────────────────────────────────────────
# RDS Subnet Group
# ─────────────────────────────────────────────
resource "aws_db_subnet_group" "dbsubnet" {
  name       = "fullstack-db-subnet"
  subnet_ids = module.vpc.private_subnets
}

# ─────────────────────────────────────────────
# RDS PostgreSQL Instance
# ─────────────────────────────────────────────
resource "aws_db_instance" "postgres" {
  identifier             = "fullstack-db"
  engine                 = "postgres"
  engine_version         = "14.18"
  instance_class         = "db.t3.micro"
  username               = var.db_master_username
  password               = var.db_master_password
  allocated_storage      = 20
  storage_type           = "gp2"
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  deletion_protection    = false
}
