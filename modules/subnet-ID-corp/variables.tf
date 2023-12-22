variable "instance_names" {
  description = "List of names for the instances for subnet-ID-corp"
  type        = list(string)
  default     = ["Ansible-controller", "K8-master", "K8-worker-node-1", "K8-worker-node-2"]
}

variable "subnet_id_ID-corp" {
  description = "Subnet ID"
  type        = string
}