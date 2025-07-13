provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# VPC par défaut
data "aws_vpc" "default" {
  default = true
}

# Liste des subnets par défaut dans le VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# AMI Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Groupe de sécurité pour SSH, Grafana, Prometheus
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Allow SSH, Grafana, and Prometheus"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-security-group"
  }
}

# Instance EC2 pour le monitoring
resource "aws_instance" "monitoring_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnets.default.ids[0] # ✅ sélection du premier subnet
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.monitoring_sg.id]

  tags = {
    Name = "monitoring-server"
  }
}
