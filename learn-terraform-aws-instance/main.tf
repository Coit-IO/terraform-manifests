terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.5.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-04b21e29a03aa7701"
  instance_type = "t2.micro"

  tags = {
    Name = "Machine1FromTerraform"
    Type = "AppServer"
    Webserver = "Nginx"
    managed-by = "Terraform"
  }
}
