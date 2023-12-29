variable "instance_names" {
  description = "List of names for the instances for subnet-AD-corp"
  type        = list(string)
  default     = ["Workstation-1", "Workstation-2"]
}

variable "subnet_id_AD-corp" {
  description = "Subnet ID"
  type        = string
}