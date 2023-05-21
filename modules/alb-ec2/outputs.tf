output "alb_dns_name" {
  description = "DNS name of the alb"
  value = aws_lb.alb.dns_name
}