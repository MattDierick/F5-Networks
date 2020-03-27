resource "azurerm_resource_group" "azure_rg" {
  name = "${var.owner}-RG"
  location = var.azure_region
  tags = {
    environment = var.owner
  }
}

resource "azurerm_virtual_network" "azurerm_virtualnet" {
    name                = "${var.owner}-VNet"
    address_space       = [var.azure_rg_cidr]
    location            = var.azure_region
    resource_group_name = azurerm_resource_group.azure_rg.name

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_subnet" "azurerm_publicsubnet1" {
    name                 = "${var.owner}-publicsubnet1"
    resource_group_name  = azurerm_resource_group.azure_rg.name
    virtual_network_name = azurerm_virtual_network.azurerm_virtualnet.name
    address_prefix       = var.public_subnet1_cidr
}

resource "azurerm_subnet" "azurerm_privatesubnet1" {
    name                 = "${var.owner}-privatesubnet1"
    resource_group_name  = azurerm_resource_group.azure_rg.name
    virtual_network_name = azurerm_virtual_network.azurerm_virtualnet.name
    address_prefix       = var.private_subnet1_cidr
}

