output "instance_ids" {
  value = [for instance in aws_instance.web-instance : instance.id]
}