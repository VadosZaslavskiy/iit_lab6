variable "vpc_id" {
  type = string
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_security_group" "docker_sg" {
  name_prefix = "docker_sg"
  description = "Security group for Docker containers"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2375
    to_port     = 2375
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "docker_instance" {
  ami                    = "ami-064087b8d355e9051"
  instance_type          = "t3.micro"
  key_name               = "lab"  
  vpc_security_group_ids = [aws_security_group.docker_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo docker pull idsad/lab45
    sudo docker run -d -p 80:80 idsad/lab45
    sudo docker pull containrrr/watchtower
    sudo docker run -d --name watchtower --restart always -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --interval 10
  EOF

  tags = {
    Name = "Docker Instance"
  }
}
