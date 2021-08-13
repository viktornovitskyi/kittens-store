locals {
  security_group_ids = compact([aws_security_group.instance-sg.id, var.rds_security_group_id])
}
data "http" "my_ip_address" {
  url = "http://ipv4.icanhazip.com"
}

data "template_file" "instance_config" {
  template = file("${path.module}/templates/entry-script.sh.tpl")
  vars = {
    database_connection_url = var.database_connection_url
  }
}

resource "aws_security_group" "instance-sg" {
  vpc_id      = var.vpc.vpc_id
  name_prefix = "tf"
  ingress {
    description = "Allow inbound SSH traffic"
    cidr_blocks = [
    "${chomp(data.http.my_ip_address.body)}/32"]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    description     = "Allow inbound HTTP traffic"
    from_port       = 80
    to_port         = 80
    security_groups = var.lb_security_groups
    protocol        = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name : "${var.project_name}-sg",
    created : "tf"
  }
}

resource "aws_instance" "web-instance" {
  for_each      = var.vpc.subnet_ids
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  subnet_id                   = each.key
  vpc_security_group_ids      = local.security_group_ids
  associate_public_ip_address = true

  user_data = data.template_file.instance_config.rendered

  tags = {
    Name : "${var.project_name}-web-instance",
    created : "tf"
  }
}
