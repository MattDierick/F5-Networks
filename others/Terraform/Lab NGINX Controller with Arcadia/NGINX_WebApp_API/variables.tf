#Define variables
variable "env" {
  description = "env: dev or prod"
}

variable "image_name" {
  description = "Image for container."
  default = "nginxplus30rc7:latest"
 }


variable "container_name" {
  type = "map"
  description = "Name of the container."
  default     = {
    dev  = "NginxPlus_dev"
    prod = "NginxPlus_prod"
  }
}

variable "int_port" {
  type = "map"  
  description = "Internal port for container."
  default     = {
    dev  = "80"
    prod = "80"
  }
}

variable "int_port_TLS" {
  description = "Internal port for container TLS."
  default = "443"
}

variable "ext_port" {
  type        = "map"
  description = "External port for container."
  default     = {
    dev  = "8080"
    prod = "8080"
  }
}

variable "ext_port_TLS" {
  description = "External port for container TLS."
  default = "8443" 
}

variable "ext_ip_Web" {
  type = "map"
  description = "External IP for container."
  default     = {
    dev  = "10.1.20.110"
    prod = "10.1.20.10"
  }
}

variable "ext_ip_API" {
  type = "map"
  description = "External IP for container."
  default     = {
    dev  = "10.1.20.109"
    prod = "10.1.20.9"
  }
}
