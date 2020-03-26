##
## azurerm provides the information to target a specific subscription/appid/tenantid/... 
## fill it if you haven't setup env variables to provide this information
##
##provider "azurerm" {
##    subscription_id = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
##    client_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
##    client_secret   = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
##    tenant_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
##}
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

module "azure_ressourcegroup" {
  source       = "../terraform_modules/azure_ressourcegroup"
  owner        = "${var.owner}-${var.project_name}"
  azure_region = var.azure_region
}

module "azure_f5_standalone" {
  source            = "../terraform_modules/azure_F5_standalone_1nic"
  azure_region      = var.azure_region
  azure_rg_name     = module.azure_ressourcegroup.azure_rg_name
  subnet1_public_id = module.azure_ressourcegroup.public_subnet1_id
  owner             = "${var.owner}-${var.project_name}"
  AllowedIPs        = var.AllowedIPs
  f5_instance_type  = var.f5_instance_type
  f5_version        = var.f5_version
  f5_image_name     = var.f5_image_name
  f5_product_name   = var.f5_product_name
  DO_URL            = var.DO_URL
  AS3_URL           = var.AS3_URL
  TS_URL            = var.TS_URL
  ADMIN_PASSWD      = data.azurerm_key_vault_secret.bigip_admin_password.value
  f5_ssh_publickey  = file(pathexpand(var.key_path))
}

module "azure_ubuntu_systems" {
  source               = "../terraform_modules/azure_nginx_systems"
  azure_region         = var.azure_region
  owner                = "${var.owner}-${var.project_name}"
  ubuntu_subnet_id_az1 = var.azure_az1
  ubuntu_subnet_id_az2 = var.azure_az2
  private_subnet1_id   = module.azure_ressourcegroup.private_subnet1_id
  public_subnet1_cidr  = module.azure_ressourcegroup.public_subnet1_cidr

  #  public_subnet2_cidr  = "${module.aws_vpc.public_subnet2_cidr}"
  private_subnet1_cidr = module.azure_ressourcegroup.private_subnet1_cidr

  #  private_subnet2_cidr = "${module.aws_vpc.private_subnet2_cidr}"
  public_key            = file(pathexpand(var.key_path))
  azure_rg_name         = module.azure_ressourcegroup.azure_rg_name
  AllowedIPs            = var.AllowedIPs
  ubuntu_instance_count = var.ubuntu_instance_count
  ubuntu_instance_size  = var.ubuntu_instance_size
  app_tag_value         = var.app_tag_value
}

data "template_file" "as3_declaration" {
  template = file("./templates/as3_declaration.tpl")
  vars = {
    azure_F5_public_ip  = module.azure_f5_standalone.f5_public_ip
    azure_f5_pool_members = join("\",\n\"", module.azure_ubuntu_systems.ubuntu_private_ips)
  }
}

resource "local_file" "as3_declaration_file" {
  content  = data.template_file.as3_declaration.rendered
  filename = "./as3_declaration.json"
}
