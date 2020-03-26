#Public IP of your BIG-IP+mgmtport in the format IP:port
f5_public_ip = "192.168.1.1"

#Mgmt port of your BIG-IP
f5_mgmt_port = "443"

#F5 BIG-IP admin user to inject declaration
f5_admin_user = "admin"

#Config name used by terraform to store state of the AS3 declaration
f5_config_name = "basic_as3_config"

#To retrieve admin password
#Azure secret RG
azure_secret_rg = "XXXXX"
#Azure vault name
azure_keyvault_name = "XXXXX"

as3_filename = "../F5_BIG_IP_Standalone_1Nic/as3_declaration.json"