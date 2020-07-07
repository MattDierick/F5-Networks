
resource "azurerm_public_ip" "ubuntu_az1_publicips" {
    count                        = var.ubuntu_instance_count
    name                         = "${var.owner}-${var.ubuntu_instance_name}-az1-public-ip-${format("%02d", count.index+1)}"
    location                     = var.azure_region
    resource_group_name          = var.azure_rg_name
    allocation_method            = "Static"
    zones                        = [var.ubuntu_subnet_id_az1]

    tags = {
        environment = "${var.owner}"
    }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = var.private_subnet1_id
  network_security_group_id = azurerm_network_security_group.azure_ubuntu_sg.id
}

resource "azurerm_network_interface" "ubuntu_az1_privatenics" {
    count                         = var.ubuntu_instance_count
    name                          = "${var.owner}-${var.ubuntu_instance_name}-az1-private-nic-${format("%02d", count.index+1)}"
    location                      = var.azure_region
    resource_group_name           = var.azure_rg_name
    #network_security_group_id     = azurerm_network_security_group.azure_ubuntu_sg.id

    ip_configuration {
        name                          = "${var.owner}-${var.ubuntu_instance_name}-az1-private-ip-${format("%02d", count.index+1)}"
        subnet_id                     = var.private_subnet1_id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = element(azurerm_public_ip.ubuntu_az1_publicips.*.id, count.index)
    }

    tags = {
        environment = var.owner
    }
}

##
## To store boot diagnostics for a VM, you need a storage account. These boot diagnostics can help you troubleshoot problems and monitor the status of your VM. The storage account you create is only to store the boot diagnostics data. As each storage account must have a unique name, the following section generates some random text:
##
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = var.azure_rg_name
    }
    
    byte_length = 8
}
resource "azurerm_storage_account" "azure_storage_account" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = var.azure_rg_name
    location            = var.azure_region
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags = {
        environment = var.owner
    }
}

data "template_file" "ubuntu_cloudinit" {
  template = file("./templates/ubuntu_cloudinit.tpl")
}

resource "local_file" "ubuntu_cloudinit" {
  content  = data.template_file.ubuntu_cloudinit.rendered
  filename = "ubuntu_cloudinit.conf"
}

resource "azurerm_virtual_machine" "azure_az1_ubuntu_vm" {
    count                 = var.ubuntu_instance_count
    name                  = "${var.owner}-ubuntu-NGINX-az1-${format("%02d", count.index+1)}"
    location              = var.azure_region
    resource_group_name   = var.azure_rg_name
    network_interface_ids = [element(azurerm_network_interface.ubuntu_az1_privatenics.*.id, count.index)]
    vm_size               = var.ubuntu_instance_size
    zones                 = [var.ubuntu_subnet_id_az1]

    # Uncomment this line to delete the OS disk automatically when deleting the VM
    delete_os_disk_on_termination = true


    # Uncomment this line to delete the data disks automatically when deleting the VM
    delete_data_disks_on_termination = true
    
    storage_os_disk {
        name              = "${var.owner}-ubuntu-NGINX-Disk-az1-${format("%02d", count.index+1)}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name   = "${var.owner}-ubuntu-NGINX-az1-${format("%02d", count.index+1)}"
        admin_username  = var.ubuntu_username
        custom_data     = data.template_file.ubuntu_cloudinit.rendered
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = var.public_key
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = azurerm_storage_account.azure_storage_account.primary_blob_endpoint
    }

    tags = {
        environment = var.owner
        Application = var.app_tag_value
    }
}