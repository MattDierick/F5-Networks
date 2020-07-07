
output "ubuntu_public_ips" {
#  value = concat(azurerm_public_ip.ubuntu_az1_publicips[*].ip_address, azurerm_public_ip.ubuntu_az2_publicips[*].ip_address)
   value = concat(azurerm_public_ip.ubuntu_az1_publicips[*].ip_address)
}

output "ubuntu_private_ips" {
#  value = concat(azurerm_network_interface.ubuntu_az1_privatenics[*].private_ip_address, azurerm_network_interface.ubuntu_az2_privatenics[*].private_ip_address)
  value = concat(azurerm_network_interface.ubuntu_az1_privatenics[*].private_ip_address)
}
