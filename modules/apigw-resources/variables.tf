variable "api" {
  description = "REST API id"
  type        = "string"
}

variable "root_resource" {
  description = "Root resource id of supplied REST API"
  type        = "string"
}

variable "resource" {
  description = "Resource name"
  type        = "string"
}

variable "methods" {
  description = "List of resource methods"
  type        = "list"
  default     = []
}

variable "num_methods" {
  description = "Number of methods"
  type        = "string"
}

variable "origin" {
  description = "Allowed CORS origin"
  type        = "string"
  default     = "*"
}

variable "authorizer_id" {
  description = "ID of authorizer"
  type        = "string"
}
