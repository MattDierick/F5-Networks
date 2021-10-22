resource "volterra_origin_pool" "sample-https-origin-pool" {
  name                   = "op-sentence-ip-tf"
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
   
  use_tls {
    use_host_header_as_sni = true
  tls_config {
    default_security = true
  }
  skip_server_verification = true
  no_mtls = true
  }

  no_tls = false
  port = "443"
  endpoint_selection     = "LOCALPREFERED"
  loadbalancer_algorithm = "LB_OVERRIDE"
}