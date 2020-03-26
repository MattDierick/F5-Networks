#Name of the owner of this deployment (no space)
owner = "User"

#Name of the project
project_name = "ExampleCloudTemplates"

#Azure Region to use
azure_region = "francecentral"

#Azure secret RG
azure_secret_rg = "RG_KeyVault"

#Azure vault name
azure_keyvault_name = "Vault"

#Azure AZ to use. Need 2
azure_az1 = "1"
azure_az2 = "2"

#Public key to use to access the instances - azure need it in this format
key_path = "~/.ssh/id_rsa.pub"

#Public IPs used to access your instances
AllowedIPs = ["80.12.58.29/32","109.7.65.101/32","92.154.17.15/32", "92.151.103.40/32", "92.151.105.23/32"]

#F5 Image to deploy
f5_version = "latest"
f5_image_name = "f5-bigip-virtual-edition-25m-best-hourly"
f5_product_name = "f5-big-ip-best"

#Value assigned to the tag key Application - will be used for AS3 Service Discovery
app_tag_value = "www-NGINX"