variable "name_prefix" {
  description = "The Name of the application or solution  (e.g. `bastion` or `portal`)"
  type        = "string"
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  type        = "string"
}

variable "description" {
  default     = ""
  description = "Description"
  type        = "string"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`)"
}
