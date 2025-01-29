provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "git_instance_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Define the key pair
resource "aws_key_pair" "ansible_key" {
  key_name   = "kabid_Key_Pair"
# public_key = file(var.public_key_path)
  public_key = tls_private_key.git_instance_key.public_key_openssh

}

# Security group to allow SSH
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "http"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create AnsibleController Ubuntu EC2 instance
resource "aws_instance" "ansible_controller" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ansible_key.key_name
  security_groups = [
    aws_security_group.allow_ssh.name
  ]

  tags = {
#    Name = "ubuntu-instance-${count.index + 1}"
    Name = "AnsibleController"
  }

  # User data script to set up the instances
  user_data = <<-EOF
            #!/bin/bash
            sudo apt-get update -y
            sudo apt-get upgrade -y
            sudo apt-get install -y ansible
        EOF
}

# Create webserver Ubuntu EC2 instance
resource "aws_instance" "webserver" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ansible_key.key_name
  security_groups = [
    aws_security_group.allow_ssh.name
  ]

  tags = {
    Name = "webserver"
  }


}

