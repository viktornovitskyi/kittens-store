output "alb_aws_security_group_id" {
  value = aws_security_group.lb-public-sg.id
}

output "public_endpoint" {
  value = aws_lb.web-app-alb.dns_name
}

output "lb_target_group_arn" {
  value = aws_lb_target_group.alb-target-group.arn
}