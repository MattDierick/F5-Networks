output "f5_public_ip" {
  value = data.azurerm_public_ip.bigip1-public-ip.ip_address
}

output "f5_private_ip" {
  value = azurerm_network_interface.bigip1_nic.private_ip_address
}
output "f5_username" {
  value = var.f5_username
}