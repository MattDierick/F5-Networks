output "azure_rg_name" {
  value = module.azure_ressourcegroup.azure_rg_name
}

output "allowed_ips" {
  value = var.AllowedIPs
}
