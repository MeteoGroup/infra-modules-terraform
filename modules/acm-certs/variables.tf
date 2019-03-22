#variable "endpoints" {
#  type        = "list"
#  default     = []
#  description = "A list of names for endpoints to provide certificate"
#}

variable "endpoints" {
  default = ""
}

variable "dns_record_name" {
  type        = "string"
  default     = ""
  description = "Base DNS record name"
}

variable "zone_id" {
  type        = "string"
  default     = ""
  description = "Zone ID for record name provide above"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit', 'XYZ')`"
}
