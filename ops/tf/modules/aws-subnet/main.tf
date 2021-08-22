locals {
  availability_zones = sort(var.vpc.availability_zones)
}

resource "aws_subnet" "network" {
  count                   = length(var.cidr_blocks)
  map_public_ip_on_launch = var.is_public
  vpc_id                  = var.vpc.vpc_id
  cidr_block              = element(var.cidr_blocks, count.index)
  availability_zone       = element(var.vpc.availability_zones, count.index)
  tags                    = merge(var.tags, tomap({ "Name" = "${var.name_prefix}-${count.index}" }))
}

resource "aws_route_table_association" "global-rta-1" {
  count          = length(var.cidr_blocks)
  route_table_id = element(var.vpc.route_tables, count.index)
  subnet_id      = element(aws_subnet.network.*.id, count.index)
}
