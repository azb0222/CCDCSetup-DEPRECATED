# Output the VPC ID and subnet IDs
output "vpc_id" {
  value = aws_vpc.ccdc_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}
