locals {
  availability_zone_names = sort(var.availability_zone_names)
  default_vpc_cidr        = "10.0.0.0/16"
}
resource "aws_vpc" "global-vpc" {
  cidr_block = local.default_vpc_cidr
  tags = {
    Name : "${var.project_name}-vpc",
    created : "tf"
  }
}

resource "aws_internet_gateway" "global-igw" {
  vpc_id = aws_vpc.global-vpc.id
  tags = {
    Name : "${var.project_name}-public",
    created : "tf"
  }
}

resource "aws_subnet" "global-subnets" {
  for_each                = var.availability_zone_names
  cidr_block              = cidrsubnet(aws_vpc.global-vpc.cidr_block, 8, index(local.availability_zone_names, each.key) + 1)
  vpc_id                  = aws_vpc.global-vpc.id
  availability_zone       = each.key
  map_public_ip_on_launch = var.is_public
  tags                    = merge(var.subnet_tags, tomap({ "Name" = "${var.subnet_name_prefix}-public-${index(local.availability_zone_names, each.key)}" }))
}

resource "aws_route_table" "global-route-table" {
  vpc_id = aws_vpc.global-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.global-igw.id
  }
  tags = {
    Name : "${var.project_name}-public",
    created : "tf"
  }
}

resource "aws_route_table_association" "global-rta-1" {
  for_each       = aws_subnet.global-subnets
  route_table_id = aws_route_table.global-route-table.id
  subnet_id      = each.value.id
}
