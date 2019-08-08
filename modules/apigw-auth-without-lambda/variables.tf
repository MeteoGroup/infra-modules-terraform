variable "api_id" {}

variable "function_name" {}
variable "environment" {}

variable "authorizer_name" {
  description = "Authorizer name"
  default     = "authorizer"
}

variable "cache_ttl" {
  default = 300
}
