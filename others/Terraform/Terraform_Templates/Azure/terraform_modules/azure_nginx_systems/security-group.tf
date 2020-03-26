resource "azurerm_network_security_group" "azure_ubuntu_sg" {
    name                = "${var.owner}-ubuntu-SG"
    location            = var.azure_region
    resource_group_name = var.azure_rg_name
    
    security_rule {
        name                       = "SSH_From_Outside"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = var.AllowedIPs
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "SSH"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = [var.public_subnet1_cidr, var.private_subnet1_cidr]  
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP_From_Outside"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefixes    = var.AllowedIPs
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP"
        priority                   = 1005
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefixes    = [var.public_subnet1_cidr, var.private_subnet1_cidr]
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPS_From_Outside"
        priority                   = 1006
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefixes    = var.AllowedIPs
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPS"
        priority                   = 1007
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefixes    = [var.public_subnet1_cidr, var.private_subnet1_cidr]  
        destination_address_prefix = "*"
    }
}