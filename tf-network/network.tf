/*
  AWS Provider
 */
provider "aws" {
  region = "us-east-1" # Set your desired AWS region here
}

/*
  2 VPCS: 
  ccdc_blue_team: 10.0.0.0/16
  ccdc_red team: #TODO
*/
resource "aws_vpc" "ccdc_blue_team" {
  cidr_block = "10.0.0.0/16" # Specify the CIDR block for your VPC
}


/*
  3 SUBNETS: 
  Public: 10.0.0.0/24
  AD_Corp: 10.0.1.0/24
  Id_Corp: 10.0.2.0/24
*/
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.ccdc_blue_team.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.ccdc_blue_team.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = count.index == 0 ? "us-east-1b" : "us-east-1c"

  tags = {
    Name = count.index == 0 ? "AD_Corp" : "ID_Corp"
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

  depends_on = [aws_internet_gateway.internet_gateway]
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
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
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
  subnet_id      = aws_subnet.private_subnet[0].id
  route_table_id = aws_route_table.AD_Corp_rt.id
}

resource "aws_route_table" "ID_Corp_rt" {
  vpc_id = aws_vpc.ccdc_blue_team.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "ID_Corp_rt_a" {
  subnet_id      = aws_subnet.private_subnet[1].id
  route_table_id = aws_route_table.ID_Corp_rt.id
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
  vpc_id      = aws_vpc.ccdc_blue_team.id

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
  vpc_id      = aws_vpc.ccdc_blue_team.id

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

# temporarily allows for ssh access from my computer 
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Security group to allow SSH access"
  vpc_id      = aws_vpc.ccdc_blue_team.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP address/range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}


/*
  FILES - generate inventory files for Ansible: 
*/ 


//creates a variable file - could be used as ansible vpn variables ? TODO: figure out 
# resource "local_file" "tf_ansible_vpn_vars" {
#   content = <<-DOC
#     tf_vpn_server_ip: ${aws_instance.vpn_instance.public_ip}
#     DOC

#   filename = "./tf_ansible_vars.yml"
# }

resource "local_file" "tf_ansible_vpn_inventory" {  
  content = <<-DOC
    [vpn] 
    ${aws_instance.vpn_instance.public_ip}
    DOC

  filename = "./ansible/playbooks/vpn/inventory.ini"
}