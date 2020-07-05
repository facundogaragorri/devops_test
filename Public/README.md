# Terraform Stack 
## Nginx & Apache Web Servers on Ec2 Instances behind a Applicationc Load Balancer
## Terraform configuration to launch Nginx & Apache Web Servers on Ec2 Instances behind a Applicationc Load Balancer

- VPC with 2 AZs with a public for each AZs
 
- 2 Instances in public subnets behind a ALB (balancing with Roubn Robin Algorithm)

 - 1 With Apache Web Server

 - 1 With Nginx Web Server
  
Each EC2 instance are launched in diferent availability zone
The load balancer and EC2 instances are launched in a **custom VPC**, and use custom security groups.

## Files
+ `provider.tf` - AWS Provider config.
+ `versions.tf` - Config of Terraform Version needed 
+ `vpc.tf` - Launches VPC, subnets, route tables, etc.
+ `ec2.tf` - Launches EC2 instances, during initialization each instance installs diferent web server
+ `alb.tf` - Launches elastic load balancer , listener, target group, etc 
+ `vars.tf` - Variables file, used by other files, sets default AWS region, calculates availability zones, etc.
+ `terraform.tfvars` - to set local variables values to pass to `vars.tf` file , used to set aws_profile, key pair name, name_prefix , etc
+ `install_apache.sh` - bash script to install apache web server on launch
+ `install_nginx.sh` - bash script to install nginx web server on launch
+ `tf-test.pub` - file with the pub key to authorize on the ec2 instances in case that not set existing Key Pair Name

## EC2 Instance Key Pair
You can use an existing Key Pair Name setting  `key_name = "key-name"` on  `terraform.tfvars` file
If yo not set existing key pair, was created one, and you must to put your pub ssh key on file `tf-test.pub` file, this key will be enabled on the EC2 instances to permit access via ssh.
 
## EC2 Instance AMI
Automatically its set the Ubuntu-16_04 AMI in the region selected when the stack is deployed

## EC2 Instance Public IP
Intances have default associate_public_ip_address = false
If you want to enable uncomment #public_ip = "true" on `terraform.tfvars` file.
For example enable This in case that you need to access via ssh to instances directly to instance from your local environment .
If you want you can enable a public ip from which to connect to the instances setting the var 
`whitelist-ips = ["186.139.222.183/32"]` on `terraform.tfvars` file.


## EC2 Instances Security Groups
By default only traffic on port 80 from ALB was enabled.
For example, if you want enable ssh , uncomment the SG config on  `ec2.tf`  to enable ingress to port 22.
Thi is posible from vpc (from bastion or jump server, or if you have an vpn configured)or  directly from your local environment by public ip , or private if you set a vpn to vpc.

## AWS Access credentials
This Terraform stack using default profile of AWS CLI local config ,
we can specify an alternate aws profile modifying value of variable "aws_profile" on `terraform.tfvars`  file.
 Enabling `#aws_profile = ""` and set the profile name to use.
However, we can specify an alternate US region on the command line by passing in an extra `aws_profile` argument on the command line by passing in an extra `aws_profile` argument.

## AWS Regions
The default AWS region is US East Virginia (us-east-1).  
we can specify an alternate aws profile modifying value of variable "aws_profile" on `terraform.tfvars`  file.
 Enabling `#aws_region = ""` and set the region name to use.
However, we can specify an alternate US region on the command line by passing in an extra `aws_region` argument.
For example:
```
$ terraform plan -var "aws_region=us-east-2" -var "aws_profile=other_profile" 
$ terraform apply 
$ terraform destroy -var "aws_region=us-east-2" -var "aws_profile=other_profile" 
```
Note: we can skip the keys args in the command if they are set via `terraform.tfvars` file.


## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12|
| aws | ~> 2.43 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.43 |

## Command Line Examples
To setup provisioner
```
$ terraform init
```
To launch the Stack :
```
$ terraform plan  
$ terraform apply
```
To Destroy Resources of the stack:
```
$ terraform destroy
```
## OUTPUT URL
Applying this Terraform configuration returns the load balancer's public URL on the last line of output.  This URL can be used to view the default  homepage of the web server 
