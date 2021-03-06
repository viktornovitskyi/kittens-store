locals {
  db = module.main-database
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  value = [for subnet in module.vpc.subnets : subnet.id]
}

output "availability_zones" {
  value = [for subnet in module.vpc.subnets : "${subnet.id} => ${subnet.availability_zone}"]
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

output "eks-cluster-endpoint" {
  value = module.web-eks-cluster.endpoint
}

output "eks-cluster-name" {
  value = module.web-eks-cluster.cluster_name
}

