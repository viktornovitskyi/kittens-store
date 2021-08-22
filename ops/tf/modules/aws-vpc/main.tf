resource "aws_vpc" "global-vpc" {
  cidr_block = "10.0.0.0/16"
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

resource "aws_route_table" "pubic-route-table" {
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
