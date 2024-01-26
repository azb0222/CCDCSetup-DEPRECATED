provider "aws" {
  region = "us-west-1"

  #change region
}

resource "tls_private_key" "test_wg_ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "test_wg_ssh_test" {
  key_name   = "test_wg_ssh_test"
  public_key = tls_private_key.test_wg_ssh.public_key_openssh
}


resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-1a"

  tags = {
    Name = "public"
  }
}


resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-1a"

  tags = {
    Name = "private"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "aws_internet_gateway"  # Add this line to tag the route table
  }
}


resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_security_group" "wireguard" {
  name        = "wireguard"
  description = "Allow SSH and WireGuard inbound traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Existing ingress rule for SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # New ingress rule for WireGuard
  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "private_instance" {
  name        = "private_instance"
  description = "Allow SSH inbound traffic from wireguard Host"
  vpc_id      = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [ aws_security_group.wireguard.id ]
  }
}

resource "aws_instance" "wireguard_host" {
  ami           = "ami-0ce2cb35386fc22e9"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.test_wg_ssh_test.key_name
  security_groups = [aws_security_group.wireguard.id]
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = 15
  }

  tags = {
    Name = "cptc8-wireguard_vpn" # Added tag for identifying the WireGuard VPN server
  }
}

resource "aws_instance" "private_instance" {
  ami           = "ami-0ce2cb35386fc22e9"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.private.id
  key_name      = aws_key_pair.test_wg_ssh_test.key_name
  security_groups = [aws_security_group.private_instance.id]

  tags = {
    Name = "Private Instance"
  }
}

resource "aws_instance" "windows_private_instance" {
  ami           = "ami-000e9c55dc85ff7ea"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.private.id
  key_name      = aws_key_pair.test_wg_ssh_test.key_name
  security_groups = [aws_security_group.private_instance.id]

  tags = {
    Name = "Windows Private Instance"
  }
}



resource "local_file" "private_key_file" {
  content  = tls_private_key.test_wg_ssh.private_key_pem
  filename = "${path.module}/ssh_keys/privatekey.pem"

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/ssh_keys && chmod 700 ${path.module}/ssh_keys"
  }
}
