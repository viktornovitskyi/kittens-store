provider "aws" {
  region = "eu-central-1"
}

locals {
  global_state = data.terraform_remote_state.remote
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = [
  "amazon"]

  filter {
    name = "name"
    values = [
    "amzn2-ami-hvm-2.0*"]
  }

  filter {
    name = "virtualization-type"
    values = [
    "hvm"]
  }
}

data "terraform_remote_state" "remote" {
  backend = "s3"
  config = {
    bucket = "devops-bootcamp"
    key    = "global/state.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

//module "kittens-webservers" {
//  source                       = "../modules/aws-app-instance"
//  project_name                 = var.project_name
//  ami_id                       = data.aws_ami.latest-amazon-linux-image.id
//  rds_security_group_id = [local.global_state.outputs.rds-sg-id]
//  database_connection_url      = local.global_state.outputs.database_connection_url
//  lb_security_groups              = [module.kittens-load-balancer.alb_aws_security_group_id]
//  key_name      = aws_key_pair.ssh-key.key_name
//  vpc = {
//    vpc_id     = local.global_state.outputs.vpc_id
//    subnet_ids = toset([local.global_state.outputs.subnet_ids[0]])
//  }
//}

module "kittens-load-balancer" {
  source       = "../modules/aws-lb"
  project_name = var.project_name
  instance_ids = []
  vpc = {
    vpc_id     = local.global_state.outputs.vpc_id
    subnet_ids = toset([for subnet_id in local.global_state.outputs.subnet_ids : subnet_id])
  }
}

module "kittens-autoscaler" {
  source                  = "../modules/aws-app-autoscaler"
  project_name            = var.project_name
  ami_id                  = data.aws_ami.latest-amazon-linux-image.id
  rds_security_group_id   = local.global_state.outputs.rds-sg-id
  database_connection_url = local.global_state.outputs.database_connection_url
  lb_security_groups      = [module.kittens-load-balancer.alb_aws_security_group_id]
  lb_arns                 = [module.kittens-load-balancer.lb_target_group_arn]
  key_name                = aws_key_pair.ssh-key.key_name
  vpc = {
    vpc_id     = local.global_state.outputs.vpc_id
    subnet_ids = toset([for subnet_id in local.global_state.outputs.subnet_ids : subnet_id])
  }
}