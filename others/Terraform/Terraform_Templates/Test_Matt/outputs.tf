output "azure_rg_name" {
  value = module.azure_ressourcegroup.azure_rg_name
}

output "allowed_ips" {
  value = var.AllowedIPs
}

output "f5_public_ip" {
  value = module.azure_f5_standalone.f5_public_ip
}
