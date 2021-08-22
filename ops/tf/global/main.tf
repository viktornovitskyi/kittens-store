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
  source       = "../modules/aws-vpc"
  project_name = local.project_name
}

module "public_networks" {
  source      = "../modules/aws-subnet"
  name_prefix = "eks-public"
  vpc = {
    vpc_id             = module.vpc.vpc_id
    route_tables       = [module.vpc.route_table]
    availability_zones = tolist(data.aws_availability_zones.available.names)
  }
  is_public = true
  cidr_blocks = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

module "private_networks" {
  source      = "../modules/aws-subnet"
  name_prefix = "eks-private"
  vpc = {
    vpc_id             = module.vpc.vpc_id
    route_tables       = [module.vpc.route_table]
    availability_zones = tolist(data.aws_availability_zones.available.names)
  }
  is_public = false
  cidr_blocks = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "main-database" {
  source  = "../modules/aws-rds-instance"
  db_name = "kittens_dev"
  vpc = {
    vpc_id     = module.vpc.vpc_id
    subnet_ids = [for subnet in module.private_networks.subnets : subnet.id]
  }
}

module "web-eks-cluster" {
  source       = "../modules/aws-eks-cluster"
  cluster_name = local.cluster_name
  vpc = {
    vpc_id     = module.vpc.vpc_id
    subnet_ids = tolist(concat(module.public_networks.subnets.*.id, module.private_networks.subnets.*.id))
  }
}

module "web-eks-node-groups" {
  source           = "../modules/aws-eks-node-groups"
  project_name     = local.project_name
  eks_cluster_name = module.web-eks-cluster.cluster_name
  subnet_ids       = module.private_networks.subnets.*.id
}