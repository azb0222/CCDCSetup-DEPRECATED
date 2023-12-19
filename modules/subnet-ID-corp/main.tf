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

resource "aws_instance" "id-corp_ec2_instances" {
  count = length(var.instance_names)

  ami           = "ami-079db87dc4c10ac91"  # TODO: Specify the desired AMI ID
  instance_type = "t2.micro" # Replace with the desired instance type
  subnet_id     = var.subnet_id_ID-corp

  tags = {
    Name = element(var.instance_names, count.index)
  }
}


