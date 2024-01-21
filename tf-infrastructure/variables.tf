/* Subnet */
variable "subnets" {
  description = "A map of subnets to create"
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
    name                    = string
  }))
  default = {
    "wireguard" = {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
      name                    = "Wireguard"
    },
    "public_subnet" = {
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
      name                    = "Public"
    }, 
    #i dont think some of these should be map_public_ip_on_launch???? idfk 
    "AD_corp" = { 
      cidr_block              = "10.0.3.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
      name                    = "AD_corp"
    }
     "ID_corp" = { 
      cidr_block              = "10.0.4.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
      name                    = "ID_corp"
    }
  }
}
