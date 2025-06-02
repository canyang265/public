packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "amazon-ebs" "nginx" {
  region          = "us-east-2"
  instance_type   = "t2.micro"
  ssh_username    = "ec2-user"
  
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  
  ami_name        = "nginx-https-{{timestamp}}"
  ami_description = "Amazon Linux 2 with NGINX HTTPS support"
  
  tags = {
    Name    = "nginx-https-ami"
    OS      = "Amazon Linux 2"
    Created = "{{timestamp}}"
  }
}

build {
  sources = ["source.amazon-ebs.nginx"]
  
  provisioner "shell" {
    inline = [
      "sudo amazon-linux-extras install python3.8 -y",
      "sudo ln -sf /usr/bin/python3.8 /usr/bin/python3",
      "sudo ln -sf /usr/bin/pip3.8 /usr/bin/pip3"
    ]
  }
  
  provisioner "ansible" {
    playbook_file = "./nginx-setup.yml"
    user          = "ec2-user"
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False"
    ]
    extra_arguments = [
      "--scp-extra-args", "'-O'"
    ]
  }
}