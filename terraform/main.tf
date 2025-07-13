provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
# Récupération du VPC par défaut
data "aws_vpc" "default" {
  default = true
}

# AMI Ubuntu 22.04 officielle
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

# Groupe de sécurité (SSH, Prometheus, Grafana)
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Allow SSH, Grafana and Prometheus"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

# Instance EC2
resource "aws_instance" "monitoring_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.monitoring_sg.id]

  tags = {
    Name = "monitoring-server"
  }

  # Génère automatiquement le fichier d’inventaire Ansible
  provisioner "local-exec" {
    command = <<EOT
      echo '[monitoring]' > ../ansible/hosts
      echo '${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${var.key_file}.pem' >> ../ansible/hosts
    EOT
  }
}

# Output pour récupérer l’IP publique
output "instance_ip" {
  value = aws_instance.monitoring_server.public_ip
}
