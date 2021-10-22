resource "volterra_origin_pool" "origin-dns" {
  name                   = "op-sentence-tf"
  namespace              = "m-dierick-dev"
 
   origin_servers {

    public_name {
      dns_name = "sentence.emea.f5se.com"
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

