variable "project_name" {}
variable "subnet_name_prefix" {}
variable "is_public" { default = false }
variable "availability_zone_names" {
  type = set(string)
}
variable "subnet_tags" {
  type        = map(string)
  default     = {}
  description = "Network tags"
}