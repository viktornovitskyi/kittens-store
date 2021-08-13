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

resource "aws_launch_configuration" "as-web-instance" {
  image_id                    = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  name_prefix                 = "terraform-lc-example-"
  associate_public_ip_address = true
  user_data                   = data.template_file.instance_config.rendered
  security_groups             = local.security_group_ids
}

resource "aws_autoscaling_group" "as-web-instance" {
  launch_configuration      = aws_launch_configuration.as-web-instance.id
  vpc_zone_identifier       = var.vpc.subnet_ids
  min_size                  = 3
  max_size                  = 6
  health_check_type         = "ELB"
  health_check_grace_period = 120
  target_group_arns         = var.lb_arns

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-web-instance-ASG"
    propagate_at_launch = true
  }
}