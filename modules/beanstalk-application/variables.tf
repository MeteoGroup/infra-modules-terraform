variable "name_prefix" {
  description = "The Name of the application or solution  (e.g. `bastion` or `portal`)"
  type        = "string"
  default     = ""
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  type        = "string"
  default     = ""
}

variable "description" {
  description = "Description"
  type        = "string"
  default     = ""
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`)"
  type        = "map"
  default     = {}
}
