variable "project_name" {}
variable "is_public" { default = false }
variable "default_vpc_cidr" { default = "10.0.0.0/16" }
variable "availability_zone_names" {
  type = set(string)
}