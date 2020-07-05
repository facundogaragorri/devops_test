provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
  version = "~> 2.43.0"
}