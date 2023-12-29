# data "aws_ami" "ubuntu" { #TODO:make my own AMI later?. use data block to fetch information about aws AMI, need AMI for windows too
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

#TODO: eventually get rid of ssh keys 

resource "aws_instance" "id-corp_ec2_instances" {
  count = length(var.instance_names)

  ami           = "ami-079db87dc4c10ac91"  # Replace with the desired AMI ID
  instance_type = "t2.micro"               # Replace with the desired instance type
  key_name      = count.index == 0 ? aws_key_pair.deployer.key_name : ""
  subnet_id     = var.subnet_id_ID-corp
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = element(var.instance_names, count.index)
  }
}
