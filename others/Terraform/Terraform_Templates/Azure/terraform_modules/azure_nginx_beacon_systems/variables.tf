variable "amis" {
    description = "Base AMI to launch the ubuntu instances"
    default = {
        us-west-2 = "ami-0f2016003e1759f35"
        eu-west-1 = "ami-03d57c34293448f40"
    }
}
variable "ubuntu_instance_name" {
    description = "Name for your Ubuntu instances"
    default = "Ubuntu-NGINX"
}

variable "ubuntu_instance_count" {
    type = "string"
}

variable "ubuntu_instance_size" {
  type = "string"
}
variable "ubuntu_username" {
  description = "name of the user that will be created on the instance"
  default = "azureuser"
}
variable "azure_region" {
  type = "string"
}
variable "ubuntu_subnet_id_az1" {
  type = "string"
}
variable "private_subnet1_id" {
  type = "string"
}

variable "ubuntu_subnet_id_az2" {
  type = "string"
}
variable "public_key" {
  type = "string"
}
variable "azure_rg_name" {
  type = "string"
}
variable "AllowedIPs" {
  type = list(string)
}

variable "owner" {
  type = "string"
}

variable "app_tag_value" {
  type = "string"
}

variable "public_subnet1_cidr" {
  type = "string"
}

variable "private_subnet1_cidr" {
  type = "string"
}


variable "NGINX_BEACON_TOKEN" { 
  type = "string"
}