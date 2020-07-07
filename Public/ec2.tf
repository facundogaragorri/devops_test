# security group for EC2 instances
resource "aws_security_group" "ec2-sg" {
  name        = "${var.name_prefix}-ec2-SG"
  description = "Allow incoming HTTP traffic only"
  vpc_id      = aws_vpc.vpc.id

  # Ingress For Traffic on port 80 from VPC in case that we need conect to web server from VPC
  # ingress {
  #   protocol    = "tcp"
  #   from_port   = 80
  #   to_port     = 80
  #   cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
  # }

  # Ingress For Traffic on port 80 from ALB
  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = ["${aws_security_group.alb_sg.id}"]
  }

  # #If you want enable SSH on EC2 Instances, to public ip instance from authorized Public IP
  #This in case that dont have an Bastion or Jumper Instance on the same VPC
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = var.whitelist-ips
  #   description = "SSH"
  # }

  # #If you want enable SSH on EC2 Instances,in case that have an Bastion or Jumper Instance on the same VPC 
  #   ingress {
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = "tcp"
  #     cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
  #     description = "SSH"
  #   }  

  #Outbound, All traffic
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name_prefix}-ec2-SG"
  }
}

#key pair create in case that no specify existing , in this case must be set file
# in this case must be set file tf-test.pub with the pub key to authorize access
resource "aws_key_pair" "tf-test" {
  count      = var.key_name == "" ? 1 : 0
  key_name   = "${var.name_prefix}-key"
  public_key = file("tf-test.pub")
}

#obtain latest Ubuntu-16_04 AMI
data "aws_ami" "ubuntu-16_04" {
  most_recent = true
  owners      = ["099720109477"] #canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}

# EC2 instances, one per availability zone
resource "aws_instance" "apache" {
  #ami                         = lookup(var.ec2_amis, var.aws_region)
  ami                         = data.aws_ami.ubuntu-16_04.id
  associate_public_ip_address = true
  instance_type               = var.instance_type
  subnet_id                   = element(tolist(data.aws_subnet_ids.public.ids), 0)
  user_data                   = file("install_apache.sh")
  # if an existing key_pair was not set ,use the created
  key_name               = var.key_name == "" ? aws_key_pair.tf-test[0].key_name : var.key_name
  vpc_security_group_ids = ["${aws_security_group.ec2-sg.id}", ]

  tags = {
    Name = "${var.name_prefix}-Apache-server"
  }
  depends_on = [aws_subnet.public]
}

resource "aws_instance" "nginx" {
  #ami                         = lookup(var.ec2_amis, var.aws_region)
  ami                         = data.aws_ami.ubuntu-16_04.id
  associate_public_ip_address = true
  instance_type               = var.instance_type
  subnet_id                   = element(tolist(data.aws_subnet_ids.public.ids), 1)
  user_data                   = file("install_nginx.sh")
  # if an existing key_pair was not set ,use the created
  key_name               = var.key_name == "" ? aws_key_pair.tf-test[0].key_name : var.key_name
  vpc_security_group_ids = ["${aws_security_group.ec2-sg.id}"]

  tags = {
    Name = "${var.name_prefix}-Nginx-server"
  }
  depends_on = [aws_subnet.public]
}