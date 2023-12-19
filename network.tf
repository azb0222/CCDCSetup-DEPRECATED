 # Define the AWS provider
provider "aws" {
  region = "us-east-1"  # Set your desired AWS region here
}

# Create a VPC
resource "aws_vpc" "ccdc_vpc" {
  cidr_block = "10.0.0.0/16"  # Specify the CIDR block for your VPC
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  count                  = 1
  vpc_id                 = aws_vpc.ccdc_vpc.id
  cidr_block             = "10.0.0.0/24"  # Specify the CIDR block for your public subnet
  availability_zone      = "us-east-1a"   # Specify the desired availability zone
  map_public_ip_on_launch = true           # Enable auto-assigning public IP addresses to instances
  tags = { 
    Name = "Public"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.ccdc_vpc.id
  cidr_block              = "10.0.${count.index+1}.0/24"  # Adjust CIDR blocks for your private subnets
  availability_zone       = count.index == 0 ? "us-east-1b" : "us-east-1c"  # Conditionally set availability zone

  tags = {
    Name =  count.index == 0 ? "AD_Corp" : "ID_Corp"
  }
}


/*
  3 SUBNETS: 
  Public: 10.0.0.0/24
  AD_Corp: 10.0.1.0/24
  Id_Corp: 10.0.2.0/24
*/