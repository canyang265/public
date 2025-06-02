variable "aws_region" {
  default = "us-east-2"
}

variable "key_pair_name" {
  default = "practice-ec2-key-pair"
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "windows_nginx_https" {
  most_recent = true
  owners      = ["self"]
  
  filter {
    name   = "name"
    values = ["windows-nginx-*"]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_vpc" "practice" {
  filter {
    name   = "tag:Name"
    values = ["practice-vpc"]
  }
}

data "aws_subnet" "public" {
  filter {
    name   = "tag:Name"
    values = ["practice-public-subnet-1"]
  }
}

data "aws_security_group" "ec2" {
  filter {
    name   = "tag:Name"
    values = ["ec2-practice-sg"]
  }
}

resource "aws_instance" "windows_nginx_https" {
  ami                    = data.aws_ami.windows_nginx_https.id
  instance_type          = "t3.small"
  key_name               = var.key_pair_name
  vpc_security_group_ids = [data.aws_security_group.ec2.id]
  subnet_id              = data.aws_subnet.public.id

  # Windows instances need more time to initialize
  timeouts {
    create = "10m"
  }

  tags = {
    Name = "windows-nginx-https-from-ami"
    Type = "Windows NGINX HTTPS Server"
  }
}

output "nginx_https_url" {
  value = "https://${aws_instance.windows_nginx_https.public_ip}"
}

output "instance_id" {
  value = aws_instance.windows_nginx_https.id
}

output "public_ip" {
  value = aws_instance.windows_nginx_https.public_ip
}