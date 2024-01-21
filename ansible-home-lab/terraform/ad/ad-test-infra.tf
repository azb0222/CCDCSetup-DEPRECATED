provider "aws" {
  region = "us-west-2" 
}

resource "aws_vpc" "AD_VPC" {
  cidr_block = "10.0.0.0/16" 
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "AD_VPC"
  }
}

resource "aws_internet_gateway" "AD_igw" {
  vpc_id = aws_vpc.AD_VPC.id
}

resource "aws_subnet" "AD_VPC_subnet1" {
  vpc_id            = aws_vpc.AD_VPC.id
  cidr_block        = "10.0.0.0/24" 
  availability_zone = "us-west-2a" 
  map_public_ip_on_launch = true 
}

resource "aws_subnet" "AD_VPC_subnet2" {
  vpc_id            = aws_vpc.AD_VPC.id
  cidr_block        = "10.0.1.0/24" 
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true 
}

resource "aws_security_group" "AD_VPC_sg" {
  name        = "AD_VPC_Security_Group"
  description = "Security group for AD VPC"
  vpc_id      = aws_vpc.AD_VPC.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.AD_VPC.cidr_block]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["24.147.194.117/32"] # RDP access from your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AD_VPC_sg"
  }
}


resource "aws_directory_service_directory" "umasscybersec_ad" {
  name     = "corp.umasscybersec.com"
  password = "zuni497RANT!"
  size     = "Small"

  vpc_settings {
    vpc_id     = aws_vpc.AD_VPC.id
    subnet_ids = [aws_subnet.AD_VPC_subnet1.id, aws_subnet.AD_VPC_subnet2.id]
  }

  tags = {
    Project = "umasscybersec_ad"
  }
}

resource "aws_iam_role" "EC2DomainJoin_role" {
  name = "EC2DomainJoin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Role = "EC2DomainJoin"
  }
}

resource "aws_iam_role_policy_attachment" "SSMManagedInstanceCore" {
  role       = aws_iam_role.EC2DomainJoin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "SSMDirectoryServiceAccess" {
  role       = aws_iam_role.EC2DomainJoin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
}


resource "aws_iam_instance_profile" "EC2DomainJoin_profile" {
  name = "EC2DomainJoin_profile"
  role = aws_iam_role.EC2DomainJoin_role.name
}

resource "tls_private_key" "ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ssh_key_pair_k8" {
  key_name   = "ssh_key_pair_k8"
  public_key = tls_private_key.ssh_private_key.public_key_openssh
}

//https://stackoverflow.com/questions/59989650/join-ec2-instance-to-ad-domain-via-terraform do some shit like this 
//something with how the vpc is setup is causing a problem where i cant connect via rdp
resource "aws_instance" "EC2DomainJoin_instance" {
  ami           = "ami-01baa2562e8727c9d" # ami for windows server
  instance_type = "t3.micro"     
  subnet_id     = aws_subnet.AD_VPC_subnet1.id
  vpc_security_group_ids = [aws_security_group.AD_VPC_sg.id]
  associate_public_ip_address = true 
  key_name                    = aws_key_pair.ssh_key_pair_k8.key_name
  iam_instance_profile = aws_iam_instance_profile.EC2DomainJoin_profile.name

  tags = {
    Name = "corp.umasscybersec.com-mgmt"
  }
}

resource "local_file" "private_key_file" {
  content  = tls_private_key.ssh_private_key.private_key_pem
  filename = "${path.module}/ssh_keys/privatekey.pem"

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/ssh_keys && chmod 700 ${path.module}/ssh_keys"
  }
}
