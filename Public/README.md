# Terraform Stack 
## Nginx & Apache Web Servers on Ec2 Instances behind a Applicationc Load Balancer
=======
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

## Access credentials
This TF using default profile of AWS CLI local config , if you want to change modify value of variable "aws_profile" , as same with de aws_region
as default use us-east-1

## Command Line Examples
To setup provisioner
```
$ terraform init
```
To launch the Stack :
```
$ terraform plan -out=aws.tfplan -var "aws_profile=······" 
$ terraform apply aws.tfplan
```
To Destroy Resources of the stack:
```
$ terraform destroy -var "aws_access_key=······" -var "aws_secret_key=······"
```
Note: we can skip the keys args in the command if they are set via shell/env exported variables.

## Regions
The default AWS region is US East Virginia (us-east-1).  However, we can specify an alternate US region on the command line by passing in an extra `aws_region` argument.  Legal values are `us-east-1`, `us-east-2`, `us-west-1`, and `us-west-2` (default).  For example:
```
$ terraform plan -out=aws.tfplan -var "aws_access_key=······" -var "aws_secret_key=······" -var "aws_region=us-east-2"
$ terraform apply aws.tfplan
$ terraform destroy -var "aws_access_key=······" -var "aws_secret_key=······" -var "aws_region=us-east-2"
```
Note: we can skip the keys args in the command if they are set via shell/env exported variables.

## URL
Applying this Terraform configuration returns the load balancer's public URL on the last line of output.  This URL can be used to view the default nginx homepage.
