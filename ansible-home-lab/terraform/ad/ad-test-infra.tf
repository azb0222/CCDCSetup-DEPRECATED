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
resource "aws_internet_gateway" "AD_igw" {
  vpc_id = aws_vpc.AD_VPC.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.AD_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.AD_igw.id
  }

  tags = {
    Name = "cptc8-def_route_table"  # Add this line to tag the route table
  }
}

resource "aws_route_table_association" "AD_VPC_subnet2" {
  subnet_id      = aws_subnet.AD_VPC_subnet1.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.AD_VPC_subnet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "AD_VPC_sg" {
  name        = "AD_VPC_Security_Group"
  description = "Security group for AD VPC"
  vpc_id      = aws_vpc.AD_VPC.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.AD_VPC.cidr_block] //all traffic within the VPC allowed 
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks =  ["0.0.0.0/0"] # change this to IP of wireguard server later
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

/*
Users: 
asritha@umasscybersec.com
ihatedevops32!

*/
resource "aws_directory_service_directory" "umasscybersec_ad" {
  name     = "umasscybersec.com"
  password = "deeznuts69420!"
  // The admin account credentials would be: 
  // username: umasscybersec\Admin
  // password: deeznuts69420!
  edition  = "Standard"
  type     = "MicrosoftAD"

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
  // "This policy provides the minimum permissions necessary to use the Systems Manager service."
}

resource "aws_iam_role_policy_attachment" "SSMDirectoryServiceAccess" {
  role       = aws_iam_role.EC2DomainJoin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
  // "The policy provides the permissions to join instances to an Active Directory managed by AWS Directory Service."
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
resource "aws_instance" "EC2DomainJoin_instance" { #TODO change all these names so they make more sense 
  ami           = "ami-01baa2562e8727c9d" # ami for windows server, im using 2019 which is boof 
  instance_type = "t3.micro"     
  subnet_id     = aws_subnet.AD_VPC_subnet1.id
  vpc_security_group_ids = [aws_security_group.AD_VPC_sg.id]
  associate_public_ip_address = true 
  key_name                    = aws_key_pair.ssh_key_pair_k8.key_name
  iam_instance_profile = aws_iam_instance_profile.EC2DomainJoin_profile.name
  //domain join directory?? see stack overflow

  tags = {
    Name = "umasscybersec.com-mgmt"
  }
} 
data "aws_directory_service_directory" "my_domain_controller" { #SO DO I NEED THIS? 
  directory_id = aws_directory_service_directory.umasscybersec_ad.id 
}
resource "aws_ssm_document" "ad-join-domain" {
  name          = "ad-join-domain"
  document_type = "Command"
  content = jsonencode(
    {
      "schemaVersion" = "2.2"
      "description"   = "aws:domainJoin"
      "mainSteps" = [
        {
          "action" = "aws:domainJoin",
          "name"   = "domainJoin",
          "inputs" = {
            "directoryId" : data.aws_directory_service_directory.my_domain_controller.id,
            "directoryName" : data.aws_directory_service_directory.my_domain_controller.name
            "dnsIpAddresses" : sort(data.aws_directory_service_directory.my_domain_controller.dns_ip_addresses)
          }
        }
      ]
    }
  )
}

resource "aws_ssm_association" "windows_server" {
  name = aws_ssm_document.ad-join-domain.name
  targets {
    key    = "InstanceIds"
    values = [aws_instance.EC2DomainJoin_instance.id]
  }
}
resource "local_file" "private_key_file" {
  content  = tls_private_key.ssh_private_key.private_key_pem
  filename = "${path.module}/ssh_keys/privatekey.pem"

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/ssh_keys && chmod 700 ${path.module}/ssh_keys"
  }
}
