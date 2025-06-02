variable "aws_region" {
  default = "us-east-2"
}

variable "key_pair_name" {
  default = "practice-ec2-key-pair"
}

data "aws_ami" "nginx_https" {
  most_recent = true
  owners      = ["self"]
  
  filter {
    name   = "name"
    values = ["nginx-https-*"]
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

resource "aws_instance" "nginx_https" {
  ami                    = data.aws_ami.nginx_https.id
  instance_type          = "t2.micro"
  key_name               = var.key_pair_name
  vpc_security_group_ids = [data.aws_security_group.ec2.id]
  subnet_id              = data.aws_subnet.public.id

  tags = {
    Name = "nginx-https-from-ami"
  }
}

output "nginx_https_url" {
  value = "https://${aws_instance.nginx_https.public_ip}"
}

output "ssh_command" {
  value = "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.nginx_https.public_ip}"
}