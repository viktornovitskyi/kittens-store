variable "cluster_name" {}
variable "vpc" {
  type = object({
    vpc_id     = string
    subnet_ids = set(string)
  })
  description = "VPC info"
}