resource "aws_lb" "web-app-alb" {
  name_prefix        = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-public-sg.id]
  subnets            = var.vpc.subnet_ids

  tags = {
    Name : "${var.project_name}-alb",
    created : "tf"
  }
}
resource "aws_security_group" "lb-public-sg" {
  vpc_id      = var.vpc.vpc_id
  name_prefix = "lb-sg"

  ingress {
    description = "Allow inbound HTTP traffic"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
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
    Name : "${var.project_name}-alb-sg",
    created : "tf"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.web-app-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-group.arn
  }
}

resource "aws_lb_target_group" "alb-target-group" {
  name     = "instance-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc.vpc_id

  health_check {
    path                = "/kittens/info"
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "tg-attachment" {
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.alb-target-group.arn
  target_id        = element(var.instance_ids, count.index)
  port             = 80
}
