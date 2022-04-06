terraform {
  backend "s3" {
    bucket = "coit-terraform-statebucket"
    key    = "ecommerce.tfstate"
    region = "ap-south-1"
  }
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

variable "vpcCidr" {
  type = string
  default = "10.10.0.0/16"
}

resource "aws_vpc" "ecommerce-vpc" {
  cidr_block = "${var.vpcCidr}"
}

variable "subnet1aCidr" {
  type = string
  default = "10.10.1.0/24"
}
resource "aws_subnet" "subnet_1a" {
  vpc_id     = aws_vpc.ecommerce-vpc.id
  cidr_block = "${var.subnet1aCidr}"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "subnet-1a"
  }
}

variable "subnet1bCidr" {
  type = string
  default = "10.10.2.0/24"  
}
resource "aws_subnet" "subnet_1b" {
  vpc_id     = aws_vpc.ecommerce-vpc.id
  cidr_block = "${var.subnet1bCidr}"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "subnet-1b"
  }
}


variable "subnet1cCidr" {
  type = string
  default = "10.10.3.0/24"  
}

resource "aws_subnet" "subnet_1c" {
  vpc_id     = aws_vpc.ecommerce-vpc.id
  cidr_block = "${var.subnet1cCidr}"
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

variable "imageId" {
  type = string
  default = "ami-0cfe39d5e0c8e331a"
}

variable "instanceType" {
  type = string
  default = "t3.micro"
}

variable "machineCount" {
  type = string
  default = 4
}

resource "aws_instance" "web001" {
  count = "${var.machineCount}"
  ami           = "${var.imageId}"
  instance_type = "${var.instanceType}"
  subnet_id = aws_subnet.subnet_1a.id
  vpc_security_group_ids = [ aws_security_group.webservers.id ]
  key_name = "mar22"
  tags = {
    Name = "Web-${count.index + 1}"
  }
}

resource "aws_instance" "web002" {
  ami           = "ami-0cfe39d5e0c8e331a"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet_1b.id
  vpc_security_group_ids = [ aws_security_group.webservers.id ]
  key_name = "mar22"
  tags = {
    Name = "Web002"
  }
}

resource "aws_instance" "web003" {
  ami           = "ami-0cfe39d5e0c8e331a"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet_1b.id
  vpc_security_group_ids = [ aws_security_group.webservers.id ]
  key_name = "mar22"
  tags = {
    Name = "Web003"
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

variable "allowSshAccessCidr" {
  type = string
  default = "0.0.0.0/0"
}

resource "aws_security_group" "webservers" {
  name        = "webservers-80"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.ecommerce-vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.allowSshAccessCidr}"]
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

resource "aws_lb_target_group" "mywebservergroup" {
  name     = "webservergroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ecommerce-vpc.id
}

resource "aws_lb_target_group_attachment" "attach_web001_tg" {
  count = length(aws_instance.web001)
  target_group_arn = aws_lb_target_group.mywebservergroup.arn
  target_id        = aws_instance.web001[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach_web002_tg" {
  target_group_arn = aws_lb_target_group.mywebservergroup.arn
  target_id        = aws_instance.web002.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach_web003_tg" {
  target_group_arn = aws_lb_target_group.mywebservergroup.arn
  target_id        = aws_instance.web003.id
  port             = 80
}


resource "aws_security_group" "lb_webservers" {
  name        = "lb-webservers-80"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.ecommerce-vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
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

resource "aws_launch_configuration" "ecommerce-lc" {
  name          = "ecommerce-lc"
  image_id      = "ami-0cfe39d5e0c8e331a"
  instance_type = "t2.micro"
  security_groups = [ aws_security_group.webservers.id ]
  key_name = "mar22"
}