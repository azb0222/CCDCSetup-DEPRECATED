//contains bucket to store Terraform state files 
terraform {
  backend "s3" {
    bucket                  = "ccdc-test-infra-state-file"
    key                     = "my-terraform-project"
    region                  = "us-east-2"
  }
}
 

//modules
module "connection-machines" { 
  source = "./modules/connection-machines"
  subnet_id_connection_machine = aws_subnet.subnets["connection_machines"].id
  vpc_id = aws_vpc.ccdc_setup.id
}

module "wireguard" { 
  source = "./modules/wireguard"
}

module "subnet-public" {
    source = "./modules/subnet-public"
    subnet_id-public = aws_subnet.subnets["public_subnet"].id
}

module "subnet-AD-corp" {
    source = "./modules/subnet-AD-corp"
    subnet_id_AD-corp = aws_subnet.subnets["AD_corp"].id
}
module "subnet-ID-corp" {
    source = "./modules/subnet-ID-corp"
    subnet_id_ID-corp =  aws_subnet.subnets["ID_corp"].id

    security_group_id = aws_security_group.workstation-security-group.id
}