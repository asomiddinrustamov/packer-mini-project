packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "ansible_playbook_file" {
  default = "./rhel.yml"
}

variable "ansible_command" {
  default = "ansible-playbook"
}

variable "aws_region" {}
variable "ami_regions" {}
variable "linux_build_instance_type" {}
variable "linux_base_ami_name" {}
variable "linux_base_ami_owner" {}
variable "root_volume_size_Gi" {}
variable "root_volume_type" {}
variable "ssh_username" {}

source "amazon-ebs" "example" {
  ami_name    = "hardened_rhel9"
  region      = var.aws_region
  ami_regions = [var.ami_regions]
  instance_type = var.linux_build_instance_type

  source_ami_filter {
    filters = {
      "virtualization-type" = "hvm"
      "name"                = var.linux_base_ami_name
      "root-device-type"    = "ebs"
    }
    owners      = [var.linux_base_ami_owner]
    most_recent = true
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = var.root_volume_size_Gi
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  ssh_username = var.ssh_username

  tags = {
    Name       = "rhel9-gold"
    OS_Version = "RHEL9"
    ENV        = "TuranCyberHub"
  }
}

build {
  sources = [
    "source.amazon-ebs.example"
  ]

  provisioner "shell" {
    inline = [
      "sleep 15"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm",
      "sudo dnf -y update",
      "sudo dnf -y install unzip wget jq",
      "sudo dnf -y install python3 python3-pip python3-setuptools python3-libs",
      "curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip",
      "cd /tmp; unzip awscliv2.zip; rm -f /tmp/awscliv2.zip",
      "sudo /tmp/aws/install -i /usr/local/aws-cli -b /usr/bin"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo reboot"
    ]
    expect_disconnect = true
  }

  provisioner "ansible" {
    command        = var.ansible_command
    playbook_file  = var.ansible_playbook_file
    user           = var.ssh_username
    extra_arguments = []
  }

  provisioner "shell" {
    execute_command = "echo 'ClamAV' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    script          = "../../../shellscripts/linux/clamav.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo dnf clean all",
      "sudo rm -rf /var/cache/dnf"
    ]
  }
}
