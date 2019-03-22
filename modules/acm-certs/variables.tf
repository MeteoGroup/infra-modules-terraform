variable "name" {
  description = "Name for the host part of FQDN for wich to create record and certificate"
  type        = "string"
  default     = ""
}

variable "hosted_zone_id" {
  description = "Zone ID for record name provide above"
  type        = "string"
  default     = ""
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('Project', 'ABC')`"
}
