locals {
  db      = module.main-database
  subnets = concat(module.public_networks.subnets, module.private_networks.subnets)
}
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  value = concat(module.public_networks.subnets.*.id, module.private_networks.subnets.*.id)
}

output "availability_zones" {
  value = [for subnet in local.subnets : "${subnet.id} => ${subnet.availability_zone}"]
}

output "database_host" {
  value = local.db.endpoint
}

output "rds-sg-id" {
  value = local.db.db-connection-sg-id
}

output "database_connection_url" {
  value     = "postgres://${local.db.username}:${local.db.password}@${local.db.endpoint}/${local.db.database_name}"
  sensitive = true
}

output "puts_database_connection_url" {
  value = "terraform output database_connection_url"
}

output "eks-cluster-endpoint" {
  value = module.web-eks-cluster.endpoint
}
