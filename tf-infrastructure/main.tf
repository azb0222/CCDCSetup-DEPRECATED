//contains bucket to store Terraform state files 
terraform {
  backend "s3" {
    bucket = "ccdc-test-infra-state-file"
    key    = "my-terraform-project"
    region = "us-east-2"
  }
}


//modules
module "Wireguard" {
  source              = "./modules/wireguard"
  vpc_id              = aws_vpc.ccdc_setup.id
  subnet_id-wireguard = aws_subnet.subnets["wireguard"].id
}

module "K8" {
  source              = "./modules/K8"
  vpc_id              = aws_vpc.ccdc_setup.id
  subnet_id = aws_subnet.subnets["K8"].id
}

//fix the naming for these so it matches up with the rest: 
module "AD-corp" {
  source            = "./modules/subnet-AD-corp"
  subnet_id_AD-corp = aws_subnet.subnets["AD_corp"].id
}
module "ID-corp" {
  source            = "./modules/subnet-ID-corp"
  subnet_id_ID-corp = aws_subnet.subnets["ID_corp"].id
  //is this used? idfk 
  security_group_id = aws_security_group.workstation-security-group.id
}
