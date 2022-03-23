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
  map_public_ip_on_launch = "true"

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


resource "aws_internet_gateway" "myvpc_ig" {
  vpc_id = aws_vpc.ecommerce-vpc.id

  tags = {
    Name = "myvpc_ig"
  }
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.ecommerce-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myvpc_ig.id
  }

  tags = {
    Name = "rt_public"
  }
}

resource "aws_route_table_association" "associate-1a-rt" {
  subnet_id      = aws_subnet.subnet_1a.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "associate-1b-rt" {
  subnet_id      = aws_subnet.subnet_1b.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_instance" "web001" {
  ami           = "ami-0851b76e8b1bce90b"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.subnet_1a.id

  tags = {
    Name = "Web001"
  }
}


resource "aws_instance" "web002" {
  ami           = "ami-0851b76e8b1bce90b"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet_1b.id
  tags = {
    Name = "Web002"
  }
}

resource "aws_security_group" "aws_default_sg" {
  description = "default VPC security group"
  ingress {
    description      = "HTTP from ALL Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}