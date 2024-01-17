/*
  AWS Provider
 */
provider "aws" {
  region = "us-east-1" # Set your desired AWS region here
}

/*
  1 VPC: 
  CCDC_Setup: 10.0.0.0/16
*/
resource "aws_vpc" "ccdc_setup" {
  cidr_block = "10.0.0.0/16" 
  enable_dns_hostnames = true
  enable_dns_support = true
  tags =  {
    Name = "ccdc-setup"
  }
}


/*
  5 SUBNETS: 
  Connection_Machines: 10.0.0.0/24
  Wireguard: 10.0.1.0/24
  Public: 10.0.2.0/24
  AD_Corp: 10.0.3.0/24
  Id_Corp: 10.0.4.0/24
*/


resource "aws_subnet" "subnets" {
  for_each                = var.subnets
  vpc_id                  = aws_vpc.ccdc_setup.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name = each.value.name
  }
}


/*
  INTERNET CONNECTIVITY: 
  internet_gateway 
  NAT 

*/
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.ccdc_setup.id

  tags = { 
    Name = "internet_gateway"
  }
}

resource "aws_eip" "nat" { // Elastic IP address, static public IPv4 that will be used for nat_gateway
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnets["public_subnet"].id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

/*
  ROUTE TABLES
  Public route table 
  AD_Corp route table 
  Id_Corp route table 
  format like subnet 

*/
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ccdc_setup.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_rt_a" {
  subnet_id      = aws_subnet.subnets["public_subnet"].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "AD_Corp_rt" {
  vpc_id = aws_vpc.ccdc_setup.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "AD_Corp_rt_a" {
  subnet_id      = aws_subnet.subnets["AD_corp"].id
  route_table_id = aws_route_table.AD_Corp_rt.id
}

resource "aws_route_table" "ID_Corp_rt" {
  vpc_id = aws_vpc.ccdc_setup.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "ID_Corp_rt_a" {
  subnet_id      = aws_subnet.subnets["ID_corp"].id
  route_table_id = aws_route_table.ID_Corp_rt.id
}


resource "aws_route_table" "Connection_machines_rt" { //can use one rt? 
  vpc_id = aws_vpc.ccdc_setup.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "Connection_machines_rt_a" {
  subnet_id      = aws_subnet.subnets["connection_machines"].id
  route_table_id = aws_route_table.Connection_machines_rt.id
}



/*
  SECURITY GROUPS 
  wg-bastion-security-group
  workstation-security-group
  k8-nodes-security-group
*/
resource "aws_security_group" "wg-bastion-security-group" {
  name        = "wg-bastion-security-group"
  description = "Allow access from Internet through WireGuard and SSH"
  vpc_id      = aws_vpc.ccdc_setup.id

  ingress {
    description = "SSH from the Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wireguard from the Internet"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffic"
  }
}


resource "aws_security_group" "workstation-security-group" {
  name        = "workstation-security-group"
  description = "Allow access from Wireguard Server only"
  vpc_id      = aws_vpc.ccdc_setup.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.wg-bastion-security-group.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_access_from_wireguard_only"
  }
}


/*
  FILES - generate inventory files for Ansible: 
*/ 

