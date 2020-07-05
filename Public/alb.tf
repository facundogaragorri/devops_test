# security group for application load balancer
resource "aws_security_group" "alb_sg" {
  name        = "${var.name_prefix}-alb-sg"
  description = "allow incoming HTTP traffic only"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

# using ALB - instances in public subnets
resource "aws_alb" "alb" {
  name            = "${var.name_prefix}-alb"
  security_groups = ["${aws_security_group.alb_sg.id}"]
  subnets         = data.aws_subnet_ids.public.ids
  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

# alb target group
resource "aws_alb_target_group" "tg" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    path = "/"
    port = 80
  }
  tags = {
    Name = "${var.name_prefix}-tg"
  }
}

#listener HTTP
resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.tg.arn
    type             = "forward"
  }
}


# target group attach instance1
resource "aws_lb_target_group_attachment" "tg-atach-instance1" {
  target_group_arn = aws_alb_target_group.tg.arn
  target_id        = aws_instance.apache.id
  port             = 80
}

# target group attach instance2

resource "aws_lb_target_group_attachment" "tg-atach-instance2" {
  target_group_arn = aws_alb_target_group.tg.arn
  target_id        = aws_instance.nginx.id
  port             = 80
}


# ALB DNS  return URL so that it can be used
output "url" {
  value = "http://${aws_alb.alb.dns_name}/"
}

