output "instance_public_ips" {
  value = aws_instance.id-corp_ec2_instances.*.private_ip
}
