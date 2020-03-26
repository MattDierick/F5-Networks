
output "azure_rg_name" {
  value = azurerm_resource_group.azure_rg.name
}
output "network_name" {
  value = azurerm_virtual_network.azurerm_virtualnet.name
}
output "public_subnet1_name" {
  value = azurerm_subnet.azurerm_publicsubnet1.name
}
output "public_subnet1_id" {
  value = azurerm_subnet.azurerm_publicsubnet1.id
}
output "public_subnet1_cidr" {
  value = var.public_subnet1_cidr
}
output "private_subnet1_id" {
  value = azurerm_subnet.azurerm_privatesubnet1.id
}
output "private_subnet1_cidr" {
  value = var.private_subnet1_cidr
}
