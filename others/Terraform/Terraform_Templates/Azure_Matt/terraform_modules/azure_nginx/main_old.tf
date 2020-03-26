### Provider Azure ###
### SET the Env Var accordingly ###
### https://docs.microsoft.com/fr-fr/azure/terraform/terraform-install-configure ###
### select yoru region with az account list-locations --query "[].{DisplayName:displayName, Name:name}" -o table ###
### When infra is deployed, use Ansible to deploy NGINX ###


provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using version 1.x, the "features" block is not allowed.
  version = "~>2.0"
  features {}
}

#resource "random_uuid" "rg" { }

resource "random_id" "id" {
    byte_length = 4
  }

#################################################################
################ Create prereq resources ########################
#################################################################

### Create Resource Group ###

resource "azurerm_resource_group" "myterraformgroup" {
    name     = "RG-matt-terraform-tfsta${lower(random_id.id.hex)}"
    location = "westeurope"

    tags = {
        environment = "Terraform Demo"
    }
}

### Create Network Vnet ###

resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet-matt-terraform"
    address_space       = ["10.1.0.0/16"]
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
        environment = "Terraform Demo"
    }
}

### Create Subnet ###

resource "azurerm_subnet" "myterraformsubnet-public" {
    name                 = "mySubnet-matt-terraform-public"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefix       = "10.1.10.0/24"
}

resource "azurerm_subnet" "myterraformsubnet-private" {
    name                 = "mySubnet-matt-terraform-private"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefix       = "10.1.20.0/24"
}


### Create Public IP ###

resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP-matt-terraform"
    location                     = "westeurope"
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

### Create Secure Group ###

resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup-Matt-Terraform"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  
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

  tags = {
      environment = "Terraform Demo"
  }
}

### Create Virtual NIC  ###

resource "azurerm_network_interface" "myterraformnic" {
  name                        = "myNIC-matt-terraform"
  location                    = "westeurope"
  resource_group_name         = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
      name                          = "myNicConfiguration"
      subnet_id                     = azurerm_subnet.myterraformsubnet-private.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }

  tags = {
      environment = "Terraform Demo"
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
      resource_group = azurerm_resource_group.myterraformgroup.name
  }
  
  byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
  name                        = "diag${random_id.randomId.hex}"
  resource_group_name         = azurerm_resource_group.myterraformgroup.name
  location                    = "westeurope"
  account_replication_type    = "LRS"
  account_tier                = "Standard"

  tags = {
      environment = "Terraform Demo"
  }
}

###############################################
############# Create VM #######################
###############################################


resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                  = "NGINX-matt-terraform"
  location              = "westeurope"
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
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

  tags = {
      environment = "Terraform Demo"
  }
}

##### For NGINX marketplace #####
##### Accept terms ######
##### 