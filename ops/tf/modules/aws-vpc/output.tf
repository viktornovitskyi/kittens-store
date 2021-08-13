output "vpc_id" {
  value = aws_vpc.global-vpc.id
}

output "subnets" {
  value = aws_subnet.global-subnets
}
