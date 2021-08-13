output "database_name" {
  value = aws_db_instance.main.name
}

output "username" {
  value = aws_db_instance.main.username
}

output "password" {
  value = aws_db_instance.main.password
}

output "endpoint" {
  value = aws_db_instance.main.endpoint
}

output "db-connection-sg-id" {
  value = aws_security_group.db-connection_security_group.id
}