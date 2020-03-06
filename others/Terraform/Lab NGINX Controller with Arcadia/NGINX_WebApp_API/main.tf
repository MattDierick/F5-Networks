# Start the NGINX+ Container
resource "docker_container" "NginxPlusWebApp" {
  name  = "NginxPlusWebApp"
  image = "nginxcontr3:latest"
  ports {
    internal = "${lookup(var.int_port, var.env)}"
    external = "${lookup(var.ext_port, var.env)}"
    ip = "${lookup(var.ext_ip_Web, var.env)}"
  }
  ports {
    internal = "${var.int_port_TLS}"
    external = "${var.ext_port_TLS}"
    ip = "${lookup(var.ext_ip_Web, var.env)}"
  }
  restart = "always"
  host {
    host = "controller.nginx-udf.internal"
    ip = "10.1.20.11"
  }
}

resource "docker_container" "NginxPlusAPI" {
  name  = "NginxPlusAPI"
  image = "nginxcontr3:latest"
  ports {
    internal = "${lookup(var.int_port, var.env)}"
    external = "${lookup(var.ext_port, var.env)}"
    ip = "${lookup(var.ext_ip_API, var.env)}"
  }
  ports {
    internal = "${var.int_port_TLS}"
    external = "${var.ext_port_TLS}"
    ip = "${lookup(var.ext_ip_API, var.env)}"
  }
  restart = "always"
  host {
    host = "controller.nginx-udf.internal"
    ip = "10.1.20.11"
  }
}
