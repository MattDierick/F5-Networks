### Create Public IP ###

resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "${var.owner}-publicIP1"
    location                     = var.azure_region
    resource_group_name          = var.azure_rg_name
    allocation_method            = "Dynamic"
}

### Create Secure Group ###

resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "${var.owner}-RG"
  location            = var.azure_region
  resource_group_name = var.azure_rg_name
  
  security_rule {
      name                       = "SSH"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "83.243.127.180"
      destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "83.243.127.180"
    destination_address_prefix = "*"
}
}

### Create Virtual NIC  ###

resource "azurerm_network_interface" "myterraformnic" {
  name                        = "${var.owner}-VNic"
  location                    = var.azure_region
  resource_group_name         = var.azure_rg_name

  ip_configuration {
      name                          = "${var.owner}-VNic-config"
      subnet_id                     = var.private_subnet1_id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }

}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.myterraformnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

### Create Diagnostic storage for bootslogs ###

resource "random_id" "randomId" {
  keepers = {
      # Generate a new ID only when a new resource group is defined
      resource_group = var.azure_rg_name
  }
  
  byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
  name                        = "diag${random_id.randomId.hex}"
  resource_group_name         = var.azure_rg_name
  location                    = var.azure_region
  account_replication_type    = "LRS"
  account_tier                = "Standard"

}

###############################################
############# Create VM #######################
###############################################


resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                  = "NGINX-matt-terraform"
  location              = var.azure_region
  resource_group_name   = var.azure_rg_name
  network_interface_ids = [azurerm_network_interface.myterraformnic.id]
  size                  = "Standard_DS1_v2"

  plan {
    name = "nginx"
    product = "nginx"
    publisher = "miri-infotech-pvt-ltd"
  }

  os_disk {
      name              = "myOsDisk"
      caching           = "ReadWrite"
      storage_account_type = "Premium_LRS"
  }

  source_image_reference {
      publisher = "miri-infotech-pvt-ltd"
      offer     = "nginx"
      sku       = "nginx"
      version   = "1.1.1"
  }

  computer_name  = "NGINX"
  admin_username = "dierick"
  disable_password_authentication = true
  
  admin_ssh_key {
      username       = "dierick"
      public_key     = file("/Users/dierick/.ssh/id_rsa.pub")
  }

  boot_diagnostics {
      storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }

}

##### For NGINX marketplace #####
##### Accept terms ######
##### 