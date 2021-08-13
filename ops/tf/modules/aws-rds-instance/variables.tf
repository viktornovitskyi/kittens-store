variable "db_name" {}
variable "vpc" {
  type = object({
    vpc_id     = string
    subnet_ids = list(string)
  })
  description = "VPC info"
}
