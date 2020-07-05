# one vpc to hold them all, and in the cloud bind them
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-VPC"
  }
}

# let vpc talk to the internet
resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name_prefix}-IGW"
  }
}

# create one subnet per availability zone
resource "aws_subnet" "public" {
  count                   = length(var.azs)
  availability_zone       = element(var.azs, count.index)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc.id
  tags = {
    Name = "Public-Subnet-${count.index}-${var.name_prefix}"
  }
}

# dynamic list of the subnets created above
data "aws_subnet_ids" "public" {
  depends_on = [aws_subnet.public]
  vpc_id     = aws_vpc.vpc.id
}

# main route table for vpc and subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name_prefix}-Public-Route-Table"
  }
}

# add public gateway to the route table
resource "aws_route" "public" {
  gateway_id             = aws_internet_gateway.public.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
}

# associate route table with vpc
resource "aws_main_route_table_association" "public" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.public.id
}

# and associate route table with each subnet
resource "aws_route_table_association" "public" {
  count = length(var.azs)
  #subnet_id      = element([data.aws_subnet_ids.public.ids], count.index)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "${var.name_prefix}-dhcp_options"
  }
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "this" {

  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}