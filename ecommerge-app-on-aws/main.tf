terraform {
  required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "4.5.0"
      }
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

resource "aws_vpc" "ecommerce-vpc" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_subnet" "subnet_1a" {
  vpc_id     = aws_vpc.ecommerce-vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "subnet-1a"
  }
}

resource "aws_subnet" "subnet_1b" {
  vpc_id     = aws_vpc.ecommerce-vpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "subnet-1b"
  }
}

resource "aws_subnet" "subnet_1c" {
  vpc_id     = aws_vpc.ecommerce-vpc.id
  cidr_block = "10.10.3.0/24"
  availability_zone = "ap-south-1c"
  tags = {
    Name = "subnet-1c"
  }
}

resource "aws_instance" "web001" {
  ami = "ami-000051d5c1a3d7008"
  instance_type = "t2.micro"
  tags = {
    Name = "web001"
    App = "Wordpress"
  }
  subnet_id = aws_subnet.subnet_1a.id
  vpc_security_group_ids = [aws_security_group.allow_port80.id]
}

resource "aws_instance" "web002" {
  ami = "ami-000051d5c1a3d7008"
  instance_type = "t2.micro"
  tags = {
    Name = "web002"
    App = "Wordpress"
  }
  subnet_id = aws_subnet.subnet_1b.id
  vpc_security_group_ids = [aws_security_group.allow_port80.id]
}

resource "aws_security_group" "allow_port80" {
  name        = "allow-port80"
  description = "Allow port 80 inbound traffic"
  vpc_id      = aws_vpc.ecommerce-vpc.id

  ingress {
    description      = "HTTP from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

