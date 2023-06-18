AWS ALB MODULE
- Creates vpc with two private and two public subnets
- Internet gateway and nat-gateway
- Creates 2 target groups with 2 instances in each target group.
- Additionally, s3 bucket for alb access logs
- Each instance is serving html with it's own private IP

Issues:
- Currently all instances are unhealty on alb side