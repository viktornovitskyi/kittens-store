variable "is_public" {}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Network tags"
}
variable "vpc" {
  type = object({
    vpc_id             = string
    route_tables       = list(string)
    availability_zones = list(string)
  })
  description = "VPC info"
}
variable "cidr_blocks" {}
variable "name_prefix" {}