output "vpc_id" {
  value = aws_vpc.global-vpc.id
}
output "route_table" {
  value = aws_route_table.pubic-route-table.id
}