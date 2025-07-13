data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

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

resource "aws_instance" "monitoring_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  tags = {
    Name = "monitoring-server"
  }

  provisioner "local-exec" {
    command = "echo '[monitoring]\n${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${var.key_file}.pem' > ../ansible/hosts"
  }
}
