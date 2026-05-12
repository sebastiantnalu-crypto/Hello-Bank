terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}

# Networking
module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
}

# Firewall rules    
module "security_group" {
  source       = "./modules/security-groups"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
}

# Server
module "ec2" {
  source = "./modules/ec2"
  subnet_id = module.vpc.public_subnet_id
  security_group_id = module.security_group.ec2_sg_id
  project_name = var.project_name 
}

# File storage
module "s3" {
  source = "./modules/s3"
  project_name = var.project_name 
}

# Database
module "rds" {
  source            = "./modules/rds"
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_group.rds_sg_id
  project_name      = var.project_name
  db_password       = var.db_password
}

# kubernetes cluster
module "eks" {
  source       = "./modules/eks"
  subnet_ids   = module.vpc.private_subnet_ids
  project_name = var.project_name
}

# Azure
module "azure" {
  source       = "./modules/azure"
  project_name = var.project_name
  environment  = var.environment 
}

