variable "instance_ids" {
  type = list(string)
}
variable "project_name" {}
variable "vpc" {
  type = object({
    vpc_id     = string
    subnet_ids = list(string)
  })
  description = "VPC info"
}