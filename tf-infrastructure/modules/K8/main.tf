resource "tls_private_key" "ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ssh_key_pair_k8" {
  key_name   = "ssh_key_pair_k8"
  public_key = tls_private_key.ssh_private_key.public_key_openssh
}

// Security group for the master node
resource "aws_security_group" "k8Master_security_group" {
  name        = "k8Master_sg"
  description = "Security group for master node"

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Security group for worker nodes
resource "aws_security_group" "k8Worker_security_group" {
  name        = "k8Worker_sg"
  description = "Security group for worker nodes"

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Master node instance
resource "aws_instance" "k8Master" {
  ami                         = "ami-05fb0b8c1424f266b"
  subnet_id                   = var.subnet_id
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.ssh_key_pair_k8.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.k8Master_security_group.id]

  tags = {
    Name = "k8Master"
  }
}

// Worker nodes
resource "aws_instance" "k8worker" {
  count     = 2
  ami       = "ami-05fb0b8c1424f266b"
  subnet_id = var.subnet_id
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.ssh_key_pair_k8.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.k8Worker_security_group.id]

  tags = {
    Name = "k8worker${count.index + 1}"
  }
}

resource "local_file" "private_key_file" {
  content  = tls_private_key.ssh_private_key.private_key_pem
  filename = "${path.module}/ssh_keys/privatekey.pem"

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/ssh_keys && chmod 700 ${path.module}/ssh_keys"
  }
}
