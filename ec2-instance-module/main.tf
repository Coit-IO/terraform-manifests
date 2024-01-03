terraform {
  required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "5.31.0"
      }
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"
  ami = "ami-03f4878755434977f"
  instance_type = "t2.micro"
  key_name = "basilmac"
  create_iam_instance_profile = true
}
