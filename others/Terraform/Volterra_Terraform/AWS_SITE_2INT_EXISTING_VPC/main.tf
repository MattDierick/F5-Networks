terraform {
          required_version = ">= 0.12.9, != 0.13.0"
        
          required_providers {
            volterra = {
              source = "volterraedge/volterra"
              version = ">=0.0.6"
            }
          }
        }
        provider "volterra" {
          api_cert = var.api_cert
          api_key = var.api_key
          url   = var.api_url
        }
