provider "azurerm" {
}

data "azurerm_resource_group" "rg_keyvault" {
  name = "${var.azure_secret_rg}"
}
 
data "azurerm_key_vault" "keyvault" {
  name = "${var.azure_keyvault_name}"
  resource_group_name = "${data.azurerm_resource_group.rg_keyvault.name}"
}
 
data "azurerm_key_vault_secret" "bigip_admin_password" {
  name = "bigip-admin-user-password" 
  key_vault_id = "${data.azurerm_key_vault.keyvault.id}"
}

provider "bigip" {
  address     = var.f5_public_ip
  port        = var.f5_mgmt_port
  username    = var.f5_admin_user
  password    = data.azurerm_key_vault_secret.bigip_admin_password.value
}

resource "bigip_as3"  "as3-base-declaration" {
  as3_json    = "${file(var.as3_filename)}"
  config_name = var.f5_config_name
 }