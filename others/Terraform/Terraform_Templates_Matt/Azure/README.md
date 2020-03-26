# F5 Deployment with Terraform in Azure

Here you will have access to different deployment leveraging Terraform.

the *terraform_module* directory contains modules that are re-used between the different deployment: ressource group creation, deploy F5 BIG-IP standalone, deploy ubuntu with NGINX..., ..

Make sure that your Azure credentials are set on your system (env variables): <https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure>