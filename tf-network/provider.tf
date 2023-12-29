terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 4.19.0"
   }
   tls = { 
    source = "hashicorp/tls"
    version = "~> 4.0.5"
   }
 }
}

provider "tls" {
  # Configuration options
}