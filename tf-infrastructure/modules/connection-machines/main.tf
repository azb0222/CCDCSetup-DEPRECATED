
resource "tls_private_key" "connection_machine_key" {
  count = 8
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "connection_machine_key" {
  count      = 8
  key_name   = "connection_machine_key_${count.index}"
  public_key = tls_private_key.connection_machine_key[count.index].public_key_openssh
}

resource "aws_instance" "connection_machine" {
  count                          = 8
  ami                            = "ami-0c7217cdde317cfec"
  instance_type                  = "t2.micro"
  key_name                       = aws_key_pair.connection_machine_key[count.index].key_name
  security_groups = [aws_security_group.allow_ssh.id]
  subnet_id = var.subnet_id_connection_machine

  tags = {
    Name = "Connection_Machine-${count.index}"
  }
}

resource "local_file" "private_key_file" {
  count    = 8
  content  = tls_private_key.connection_machine_key[count.index].private_key_pem
  filename = "${path.module}/ssh_keys/connection_machine_key_${count.index}.pem"
  provisioner "local-exec" {
    command = "chmod 700 ${path.module}/ssh_keys"
  }
}

locals {
  instances_info = [for i in range(8): {
      name = "Connection_Machine-${i}"
      ip   = aws_instance.connection_machine[i].public_ip
  }]
}

resource "local_file" "instance_ips" {
  content  = jsonencode(local.instances_info)
  filename = "${path.module}/instance_ips.json"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "allow_ssh"
  }
}
