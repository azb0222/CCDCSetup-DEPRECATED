//contains bucket to store Terraform state files 
terraform {
  backend "s3" {
    bucket                  = "ccdc-test-infra-state-file"
    key                     = "my-terraform-project"
    region                  = "us-east-2"
  }
}
 

//modules
module "subnet-AD-corp" {
    source = "./modules/subnet-AD-corp"
    subnet_id_AD-corp = aws_subnet.private_subnet[0].id 
}
module "subnet-ID-corp" {
    source = "./modules/subnet-ID-corp"
    subnet_id_ID-corp = aws_subnet.private_subnet[1].id 
    security_group_id = aws_security_group.allow_ssh.id
}

module "subnet-public" {
    source = "./modules/subnet-public"
    subnet_id-public = aws_subnet.public_subnet.id
}