variable "azure_rg_cidr" {
    description = "Azure Ressource Group CIDR"
    default = "10.1.0.0/16"
}

variable "public_subnet1_cidr" {
  description = "First public subnet IP range"
  default = "10.1.10.0/24"
}

variable "public_subnet2_cidr" {
  description = "2nd public subnet IP range"
  default = "10.1.11.0/24"
}

variable "private_subnet1_cidr" {
  description = "2nd public subnet IP range"
  default = "10.1.20.0/24"
}

variable "private_subnet2_cidr" {
  description = "2nd public subnet IP range"
  default = "10.1.21.0/24"
}
variable "azure_region" {
  default = westeurope
}

variable "owner" {
  type = matt-dierick
}

