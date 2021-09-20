locals {
  db = module.pr-database
}

output "database_connection_url" {
  value     = "postgres://${local.db.username}:${local.db.password}@${local.db.endpoint}/${local.db.database_name}"
  sensitive = true
}

output "eks-cluster-name" {
  value = data.terraform_remote_state.remote.outputs.eks-cluster-name
}

