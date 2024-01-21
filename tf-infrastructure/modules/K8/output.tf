output "k8Master_ip" {
  value = aws_instance.k8Master.public_ip
}

output "k8worker1_ip" {
  value = aws_instance.k8worker1.public_ip
}

output "k8worker2_ip" {
  value = aws_instance.k8worker2.public_ip
}