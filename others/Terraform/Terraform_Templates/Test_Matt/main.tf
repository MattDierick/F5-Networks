provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using version 1.x, the "features" block is not allowed.
  version = "~>2.0"
  features {}
}


module "azure_ressourcegroup" {
  source       = "../terraform_modules/azure_ressourcegroup"
  owner        = "${var.owner}-${var.project_name}"
  azure_region = var.azure_region
}

