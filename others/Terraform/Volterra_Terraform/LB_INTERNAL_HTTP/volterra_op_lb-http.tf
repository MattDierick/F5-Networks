//==========================================================================
//Definition of the Origin, 1-origin.tf
//Start of the TF file
resource "volterra_origin_pool" "sample-http-origin-pool" {
  name                   = "op-ip-internal"
  //Name of the namespace where the origin pool must be deployed
  namespace              = "m-dierick-dev"
 
   origin_servers {

    private_ip {
      ip = "10.17.20.13"

      //From which interface of the node onsite the IP of the service is reachable. Value are inside_network / outside_network or both.
      outside_network = true
     
     //Site definition
      site_locator {
        site {
          name      = "dierick-aws-eun2"
          namespace = "system"
          tenant    = ""
        }
      }
    }

    labels = {
    }
  }

  no_tls = true
  port = "80"
  endpoint_selection     = "LOCALPREFERED"
  loadbalancer_algorithm = "LB_OVERRIDE"
}
//End of the file
//==========================================================================

//==========================================================================
//Definition of the Load-Balancer, 2-http-lb.tf
//Start of the TF file
resource "volterra_http_loadbalancer" "sample-http-lb" {
depends_on = [volterra_origin_pool.sample-http-origin-pool]
//Mandatory "Metadata"
name      = "http-lb-internal"
//Name of the namespace where the origin pool must be deployed
namespace = "m-dierick-dev"
//End of mandatory "Metadata" 

//Mandatory "Basic configuration"
  domains = ["my-internal-lb.itc.demo"]
  http {
    dns_volterra_managed = false
  }
//End of mandatory "Basic configuration"

//Optional "Default Origin server"
default_route_pools {
    pool {
      name = "op-ip-internal"
      namespace = "m-dierick-dev"
    }
    weight = 1
  }
//End of optional "Default Origin server"

//Mandatory "VIP configuration"
advertise_on_public_default_vip = true
//End of mandatory "VIP configuration"

//Mandatory "Security configuration"
no_service_policies = true
no_challenge = true
disable_rate_limit = true
disable_waf = true
//End of mandatory "Security configuration"

//Mandatory "Load Balancing Control"
source_ip_stickiness = true
//End of mandatory "Load Balancing Control"
  
}
//End of the file
//==========================================================================