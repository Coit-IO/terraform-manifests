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
  map_public_ip_on_launch = "true"
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
  ami           = "ami-0cfe39d5e0c8e331a"
  instance_type = "${var.machineSize}"
  subnet_id = aws_subnet.subnet_1a.id
  vpc_security_group_ids = [ aws_security_group.webservers.id ]
  key_name = "mar22"
  tags = {
    Name = "Web001"
  }
}

resource "aws_instance" "web002" {
  ami           = "ami-0cfe39d5e0c8e331a"
  instance_type = "${var.machineSize}"
  subnet_id = aws_subnet.subnet_1b.id
  vpc_security_group_ids = [ aws_security_group.webservers.id ]
  key_name = "mar22"
  tags = {
    Name = "Web002"
  }
}

resource "aws_instance" "web003" {
  ami           = "ami-0cfe39d5e0c8e331a"
  instance_type = "${var.machineSize}"
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

resource "aws_lb_target_group" "mywebservergroup" {
  name     = "webservergroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ecommerce-vpc.id
}

resource "aws_lb_target_group_attachment" "attach_web001_tg" {
  target_group_arn = aws_lb_target_group.mywebservergroup.arn
  target_id        = aws_instance.web001.id
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

resource "aws_lb" "lb-webservers" {
  name               = "lb-webservers"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_webservers.id]
  subnets            = [ aws_subnet.subnet_1a.id, aws_subnet.subnet_1b.id ]
  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "front_end_80" {
  load_balancer_arn = aws_lb.lb-webservers.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mywebservergroup.arn
  }
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
  instance_type = "${var.machineSize}"
  security_groups = [ aws_security_group.webservers.id ]
  key_name = "basilmac"
}

variable "asgMin" {
  type = string
  default = "1"
}

variable "asgMax" {
  type = string
  default = "5"
}

variable "asgDesired" {
  type = string
  default = "2"
}

variable "machineSize" {
  type = string
  default = "t2.micro"
}


resource "aws_autoscaling_group" "ecommerce-asg" {
  name                      = "ecommerce-asg"
  max_size                  = "${var.asgMax}"
  min_size                  = "${var.asgMin}"
  desired_capacity          = "${var.asgDesired}"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.ecommerce-lc.name
  vpc_zone_identifier       = [aws_subnet.subnet_1a.id, aws_subnet.subnet_1b.id]

  tag {
    key                 = "foo"
    value               = "bar"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.ecommerce-asg.id
  alb_target_group_arn   = aws_lb_target_group.mywebservergroup.arn
}
