 /*
  AWS Provider
 */
provider "aws" {
  region = "us-east-1"  # Set your desired AWS region here
}

/*
  2 VPCS: 
  ccdc_blue_team: 10.0.0.0/16
  ccdc_red team: #TODO
*/
resource "aws_vpc" "ccdc_blue_team" {
  cidr_block = "10.0.0.0/16"  # Specify the CIDR block for your VPC
}


/*
  3 SUBNETS: 
  Public: 10.0.0.0/24
  AD_Corp: 10.0.1.0/24
  Id_Corp: 10.0.2.0/24
*/
resource "aws_subnet" "public_subnet" {
  count                  = 1
  vpc_id                 = aws_vpc.ccdc_vpc.id
  cidr_block             = "10.0.0.0/24"  
  availability_zone      = "us-east-1a" 
  map_public_ip_on_launch = true          
  tags = { 
    Name = "Public"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.ccdc_vpc.id
  cidr_block              = "10.0.${count.index+1}.0/24" 
  availability_zone       = count.index == 0 ? "us-east-1b" : "us-east-1c" 

  tags = {
    Name =  count.index == 0 ? "AD_Corp" : "ID_Corp"
  }
}

/*
  INTERNET CONNECTIVITY: 
  internet_gateway 
  NAT 

*/
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.ccdc_blue_team.id
}

resource "aws_eip" "nat" { // Elastic IP address, static public IPv4 that will be used for nat_gateway
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.gw]
}

/*
  ROUTE TABLES
  Public route table 
  AD_Corp route table 
  Id_Corp route table 

*/
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ccdc_blue_team.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway
  }
}

resource "aws_route_table_association" "public_rt_a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "AD_Corp_rt" {
  vpc_id = aws_vpc.ccdc_blue_team.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "AD_Corp_rt_a" {
  subnet_id      = aws_subnet.AD_Corp.id
  route_table_id = aws_route_table.AD_Corp_rt.id
}

/*
  SECURITY GROUPS 
  

*/