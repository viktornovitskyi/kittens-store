provider "aws" {
  region = "eu-central-1"
}

locals {
  global_state = data.terraform_remote_state.remote
  project_name = "ops-test-pr"
  cluster_name = "pr-eks"
}

data "terraform_remote_state" "remote" {
  backend = "s3"
  config = {
    bucket = "devops-bootcamp"
    key    = "global/state.tfstate"
    region = "eu-central-1"
  }
}

module "pr-database" {
  source  = "../modules/aws-rds-instance"
  db_name = "kittens_dev"
  role    = var.pull_request_id
  vpc = {
    vpc_id     = local.global_state.outputs.vpc_id
    subnet_ids = local.global_state.outputs.subnet_ids
  }
}