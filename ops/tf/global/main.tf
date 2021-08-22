provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "global-network" {
  source                  = "../modules/aws-vpc"
  project_name            = var.project_name
  availability_zone_names = toset(data.aws_availability_zones.available.names)
}

module "main-database" {
  source  = "../modules/aws-rds-instance"
  db_name = "kittens_dev"
  vpc = {
    vpc_id     = module.global-network.vpc_id
    subnet_ids = [for subnet in module.global-network.subnets : subnet.id]
  }
}

module "web-eks-cluster" {
  source       = "../modules/aws-eks-cluster"
  project_name = var.project_name
  vpc = {
    vpc_id     = module.global-network.vpc_id
    subnet_ids = [for subnet in module.global-network.subnets : subnet.id]
  }
}