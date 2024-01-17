#TODO: move to output? fix this mess of a file 
resource "tls_private_key" "ansible-controller-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "private_key_pem" {
  description = "The private key data in PEM format"
  value       = tls_private_key.ansible-controller-ssh-key.private_key_pem
  sensitive   = true
}

output "public_key_openssh" {
  description = "The public key data in OpenSSH format"
  value       = tls_private_key.ansible-controller-ssh-key.public_key_openssh
}

resource "aws_key_pair" "deployer" {
  key_name   = "ansible-controller-key"
  public_key = tls_private_key.ansible-controller-ssh-key.public_key_openssh
}
