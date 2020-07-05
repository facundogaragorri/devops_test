variable "aws_region" {
  description = "US EAST Virginia"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "aws cli profile to use on deploy"
  default     = "default"
}

# dynamically retrieves all availability zones for current region
#data "aws_availability_zones" "available" {}

# specifying AZs 
#   comment off this "azs" to retrive all AZs dynamically (uncomment the line above "data ...")
variable "azs" {
  type    = list
  default = ["us-east-1a", "us-east-1b"]
}


# variable "ec2_amis" {
#   description = "Ubuntu Server 16.04 LTS (HVM)"
#   type        = map

#   default = {
#     "us-east-1" = "ami-059eeca93cf09eebd"
#     "us-east-2" = "ami-0782e9ee97725263d"
#     "us-west-1" = "ami-0ad16744583f21877"
#     "us-west-2" = "ami-0e32ec5bc225539f5"
#   }
# }

#Ec2 Instanes Type touse
variable "instance_type" {
  default = "t2.micro"
}

variable "public_subnets_cidr" {
  type    = list
  default = ["10.0.0.0/24", "10.0.2.0/24"]
}

variable "name_prefix" {
  type = string
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