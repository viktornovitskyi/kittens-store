locals {

}
resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_db_subnet_group" "main" {
  name       = var.role
  subnet_ids = var.vpc.subnet_ids

  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_db_instance" "main" {
  engine               = "postgres"
  engine_version       = "13.1"
  db_subnet_group_name = aws_db_subnet_group.main.name
  allocated_storage    = 5
  identifier_prefix    = "kittens-rds"
  skip_final_snapshot  = true
  instance_class       = "db.t3.micro"
  port                 = "5432"
  publicly_accessible  = false
  name                 = var.db_name
  username             = "postgres"
  password             = random_password.password.result
  vpc_security_group_ids = [
  aws_security_group.db-connection_security_group.id]
}

resource "aws_security_group" "db-connection_security_group" {
  vpc_id = var.vpc.vpc_id
  name   = "${var.role}-${var.db_name}-db-connector"

  ingress {
    description = "Only postgres in"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  tags = {
    Name : "${var.db_name}-db-sg",
    created : "tf"
  }
}
