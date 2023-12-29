resource "aws_instance" "ad-corp_ec2_instances" {
  count = length(var.instance_names)

  ami           = "ami-079db87dc4c10ac91"  # TODO: change to Windows 
  instance_type = "t2.micro" # Replace with the desired instance type
  subnet_id     = var.subnet_id_AD-corp

  tags = {
    Name = element(var.instance_names, count.index)
  }
}

