variable "aws_region" {
  description = "US EAST Virginia"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "aws cli profile to use on deploy"
  default     = "default"
}

variable "azs" {
  description = "The availability zones to use for subnets and resources in the VPC. By default, all AZs in the region will be used."
  type        = list(string)
  default     = []
}

#Ec2 Instanes Type touse
variable "instance_type" {
  default = "t2.micro"
}

variable "public_subnets_cidr" {
  type    = list
  default = ["10.0.0.0/24", "10.0.2.0/24", "10.0.4.0/24"]
}

variable "name_prefix" {
  type        = string
  description = "Naming Prefix used for naming resources"
}

variable "key_name" {
  description = "SSH Key Pair Name"
  default     = ""
}

variable "whitelist-ips" {
  description = "List of public  ip adresses  to permit access to instances on port 22"
  type        = list(string)
  default     = []
}