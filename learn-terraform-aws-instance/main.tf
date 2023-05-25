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
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name      = "basilmac"
  tags = {
    Name = "Machine1FromTerraform"
    Type = "AppServer"
    Webserver = "Nginx"
    managed-by = "Terraform"
  }
}
