
resource "tls_private_key" "ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "ssh_key_pair"
  public_key = tls_private_key.ssh_private_key.public_key_openssh
}

resource "aws_instance" "wireguard_server" {
  ami                            = "ami-0c7217cdde317cfec"
  instance_type                  = "t2.micro"
  subnet_id                      = var.subnet_id-wireguard
  associate_public_ip_address    = true
  key_name                       = aws_key_pair.ssh_key_pair.key_name
  vpc_security_group_ids         = [aws_security_group.wg_sg.id]

  tags = {
    Name = "Wireguard Server"
  }
}

resource "local_file" "private_key_file" {
  content  = tls_private_key.ssh_private_key.private_key_pem
  filename = "${path.module}/ssh_keys/privatekey.pem"
  
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/ssh_keys && chmod 700 ${path.module}/ssh_keys"
  }
}

resource "local_file" "tf_ansible_vpn_vars" {
  content = <<-DOC
    tf_vpn_server_ip: ${aws_instance.wireguard_server.public_ip}
    DOC

  filename = "./tf_ansible_vars.yml"
}

resource "local_file" "inventory" {
  content = <<-DOC
    [vpn]
    ${aws_instance.wireguard_server.public_ip}
    DOC

  filename = "../ansible/playbooks/vpn/inventory.ini"
}


#modify this security group to only allow traffic from connection machine IPs? 
# as well as have to allow connection from whatever is running the ansibel playbook
resource "aws_security_group" "wg_sg" {
  name        = "wireguard-sg"
  description = "Security group for WireGuard server"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 51820  # Default WireGuard port
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from any IP
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}
