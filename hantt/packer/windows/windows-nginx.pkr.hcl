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

source "amazon-ebs" "windows-nginx" {
  ami_name      = "windows-nginx-{{timestamp}}"
  instance_type = "t3.medium"
  region        = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "Windows_Server-2022-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_use_ssl  = false
  winrm_port     = 5985
  winrm_timeout  = "15m"
  
  user_data = <<EOF
<powershell>
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985
</powershell>
EOF
}

build {
  sources = ["source.amazon-ebs.windows-nginx"]
  
  provisioner "ansible" {
    playbook_file = "./nginx-setup.yml"
    user         = "Administrator"
    use_proxy    = false
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False"
    ]
    extra_arguments = [
      "--connection=winrm"
    ]
  }
}