variable "azure_rg_name" {
    type = "string"
}
variable "f5_username" {
  description = "user of the F5 admin that will be created"
  default = "azureuser"
}
variable "azure_region" {
  type = "string"
}

variable "subnet1_public_id" {
  type = "string"
}
variable "AllowedIPs" {
  type = list(string)
}

variable "f5_instance_type" {
  type = "string"
}

variable "f5_image_name" {
  type = "string"
}
variable "f5_version" {
  type = "string"
}

variable "f5_product_name" {
  type = "string"
}

variable libs_dir { 
  default = "/config/cloud/azure/node_modules" 
}
variable onboard_log { 
  default = "/var/log/startup-script.log" 
}

variable "f5_ssh_publickey" {
  type = "string"
}
variable "owner" {
  type = "string"
}

variable "AS3_URL" { 
  type = "string"
}
variable "DO_URL" { 
  type = "string"
}

variable "TS_URL" { 
  type = "string"
}

variable "ADMIN_PASSWD" { 
  type = "string"
}

variable "F5_BEACON_TOKEN" { 
  type = "string"
}
