resource "volterra_origin_pool" "origin-dns" {
  name                   = "op-sentence-ip-tf"
  namespace              = "m-dierick-dev"
 
   origin_servers {

    public_ip {
      ip = "40.66.56.3"
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

