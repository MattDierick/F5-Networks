output "azure_rg_name" {
  value = module.azure_ressourcegroup.azure_rg_name
}

output "allowed_ips" {
  value = var.AllowedIPs
}

output "f5_public_ip" {
  value = module.azure_f5_standalone.f5_public_ip
}

output "f5_username" {
  value = module.azure_f5_standalone.f5_username
}

output "ubuntu_public_ips" {
  value = module.azure_ubuntu_systems.ubuntu_public_ips
}

output "ubuntu_private_ips" {
  value = module.azure_ubuntu_systems.ubuntu_private_ips
}

