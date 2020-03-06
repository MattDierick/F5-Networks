# Start the NGINX+ Container
resource "docker_container" "DevPortal" {
  name  = "DevPortal"
  image = "nginxcontr3:latest"
  ports {
    internal = "8090"
    external = "8090"
    ip = "10.1.20.12"
  }
  restart = "always"
  host {
    host = "controller.nginx-udf.internal"
    ip = "10.1.20.11"
  }
}
