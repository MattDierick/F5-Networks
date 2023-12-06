variable "namespace" {
   type = string
}

variable "api_token" {
   type = string
}

variable "workload_name" {
   type = string
}

variable "oas_url" {
   type = string
   default = "https://api.swaggerhub.com/apis/F5EMEASSA/API-Sentence-2022/v1"
}

variable "http_lb_domain" {
   type = string
   default = "redoc-demo-default-api.emea-ent.f5demos.com"
}
