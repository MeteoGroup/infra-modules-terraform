variable "name_prefix" {
  description = "The Name of the application or solution  (e.g. `bastion` or `portal`)"
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "description" {
  default     = ""
  description = "Description"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`)"
}
