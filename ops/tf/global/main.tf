provider "aws" {
  region = "eu-central-1"
}

locals {
  project_name = "ops-test"
  cluster_name = "eks-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source                  = "../modules/aws-vpc"
  project_name            = local.project_name
  availability_zone_names = toset(data.aws_availability_zones.available.names)
  subnet_name_prefix      = "eks-public"
  is_public               = true
  subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

module "main-database" {
  source  = "../modules/aws-rds-instance"
  db_name = "kittens_dev"
  vpc = {
    vpc_id     = module.vpc.vpc_id
    subnet_ids = [for subnet in module.vpc.subnets : subnet.id]
  }
}

module "web-eks-cluster" {
  source       = "../modules/aws-eks-cluster"
  cluster_name = local.cluster_name
  vpc = {
    vpc_id     = module.vpc.vpc_id
    subnet_ids = [for subnet in module.vpc.subnets : subnet.id]
  }
}

module "web-eks-node-groups" {
  source           = "../modules/aws-eks-node-groups"
  project_name     = local.project_name
  eks_cluster_name = module.web-eks-cluster.cluster_name
  subnet_ids       = [for subnet in module.vpc.subnets : subnet.id]
}