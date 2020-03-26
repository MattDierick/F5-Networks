
output "nginx_public_ips" {
  value = concat(azurerm_public_ip.myterraformpublicip[*].ip_address)
}

output "nginx_private_ips" {
  value = concat(azurerm_network_interface.myterraformnic[*].private_ip_address)
}
