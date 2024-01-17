output "wireguard_VPN_ip" {
  value = aws_instance.wireguard_VPN.public_ip
}
