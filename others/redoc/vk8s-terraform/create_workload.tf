locals {
        index   = templatefile("${path.module}/index.html.tmpl", {
		oas_url = var.oas_url})
        workload = templatefile("${path.module}/workload.tmpl", {
		workload_name   = var.workload_name
		namespace   = var.namespace
                http_lb_domain  = var.http_lb_domain
		index_file = base64encode(local.index)
        })
}

resource "terracurl_request" "dev-portal" {

  name         = var.workload_name
  url          = "https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/${var.namespace}/workloads"
  method       = "POST"
  request_body = local.workload
  headers = {
    Authorization = "APIToken ${var.api_token}"
  }

  response_codes = [
    200
  ]

  destroy_url    = "https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/${var.namespace}/workloads/${var.workload_name}"
  destroy_method = "DELETE"

  destroy_headers = {
    Authorization = "APIToken ${var.api_token}"
  }

  destroy_response_codes = [
    200
  ]

}
