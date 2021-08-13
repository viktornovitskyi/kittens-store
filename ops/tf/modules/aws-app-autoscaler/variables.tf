variable "project_name" {}
variable "ami_id" {}
variable "database_connection_url" {}
variable "lb_security_groups" { default = [] }
variable "lb_arns" {
  type = list(string)
}
variable "rds_security_group_id" {
  default = []
}
variable "vpc" {
  type = object({
    vpc_id     = string
    subnet_ids = set(string)
  })
  description = "VPC info"
}
variable "key_name" {}