# Create a Public IP for bigip1
resource "azurerm_public_ip" "bigip1_public_ip" {
  name                      = "${var.owner}-bigip1-public-ip"
  location                  = var.azure_region
  resource_group_name       = var.azure_rg_name
  allocation_method         = "Dynamic"

  tags = {
    Name           = "${var.owner}-bigip1-public-ip"
    owner          = var.owner
  }
}


# Create the 1nic interface for BIG-IP 01
resource "azurerm_network_interface" "bigip1_nic" {
  name                      = "${var.owner}-bigip1-mgmt-nic"
  location                  = var.azure_region
  resource_group_name       = var.azure_rg_name
  network_security_group_id = azurerm_network_security_group.bigip_sg.id

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet1_public_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bigip1_public_ip.id
  }

  tags = {
    Name           = "${var.owner}-bigip1-mgmt-nic"
    owner          = var.owner
  }
}

data "template_file" "f5_bigip_onboard" {
  template = file("./templates/f5_onboard.tpl")

  vars = {
    DO_URL          = var.DO_URL
    AS3_URL		      = var.AS3_URL
    TS_URL          = var.TS_URL
    ADMIN_PASSWD    = var.ADMIN_PASSWD
    libs_dir		    = var.libs_dir
    onboard_log		  = var.onboard_log
  }
}

# Create F5 BIGIP1
resource "azurerm_virtual_machine" "f5-bigip1" {
  name                         = "${var.owner}-f5-bigip1"
  location                     = var.azure_region
  resource_group_name          = var.azure_rg_name
  primary_network_interface_id = azurerm_network_interface.bigip1_nic.id
  network_interface_ids        = [azurerm_network_interface.bigip1_nic.id]
  vm_size                      = var.f5_instance_type
  
  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "f5-networks"
    offer     = var.f5_product_name
    sku       = var.f5_image_name
    version   = var.f5_version
  }

  storage_os_disk {
    name              = "${var.owner}-bigip1-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.owner}-bigip1-os"
    admin_username = var.f5_username
    custom_data    = data.template_file.f5_bigip_onboard.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        path     = "/home/azureuser/.ssh/authorized_keys"
        key_data = var.f5_ssh_publickey
    }
  }
  
#  os_profile_linux_config {
#    disable_password_authentication = false
#  }

  plan {
    name          = var.f5_image_name
    publisher     = "f5-networks"
    product       = var.f5_product_name
  }

  tags = {
    Name           = "${var.owner}-f5bigip1"
    owner          = var.owner
  }
}

# Run Startup Script
resource "azurerm_virtual_machine_extension" "f5-bigip1-run-startup-cmd" {
  name                 = "${var.owner}-f5-bigip1-run-startup-cmd"
  depends_on           = [azurerm_virtual_machine.f5-bigip1]
  location             = var.azure_region
  resource_group_name  = var.azure_rg_name
  virtual_machine_name = azurerm_virtual_machine.f5-bigip1.name
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {
        "commandToExecute": "bash /var/lib/waagent/CustomData"
    }
  SETTINGS

  tags = {
    Name           = "${var.owner}-f5-bigip1-startup-cmd"
    owner          = var.owner
  }
}

#Needed to retrieve the F5 public IP when doing dynamic IP allocation
data "azurerm_public_ip" "bigip1-public-ip" {
  name                = azurerm_public_ip.bigip1_public_ip.name
  resource_group_name = var.azure_rg_name

  depends_on = [azurerm_virtual_machine.f5-bigip1]
}

resource "azurerm_network_security_group" "bigip_sg" {
  name                = "${var.owner}-bigip-sg"
  location            = var.azure_region
  resource_group_name = var.azure_rg_name

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.AllowedIPs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_HTTP"
    description                = "Allow HTTP access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = var.AllowedIPs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_HTTPS"
    description                = "Allow HTTPS access"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.AllowedIPs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_RDP"
    description                = "Allow RDP access"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.AllowedIPs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_APP_HTTPS"
    description                = "Allow HTTPS access"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8443"
    source_address_prefixes    = var.AllowedIPs
    destination_address_prefix = "*"
  }

  tags = {
    Name           = "${var.owner}-bigip-sg"
    owner          = var.owner
  }
}