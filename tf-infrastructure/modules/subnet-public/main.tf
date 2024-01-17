resource "aws_instance" "wireguard_VPN" {
  ami           = "ami-079db87dc4c10ac91"  # Replace with the desired AMI ID
  instance_type = "t2.micro"               # Replace with the desired instance type
  subnet_id     = var.subnet_id-public
  associate_public_ip_address = true

  tags = {
    Name = "wireguard_VPN"
  }
}
