variable "name_prefix" {}

variable "tags" {
  type = "map"
}

variable "job_vcpus" {}
variable "job_memory" {}

variable "instance_type" {}

variable "subnets" {
  type    = "list"
  default = []
}

variable "security_group" {}

variable "job_policy_document" {}

variable "repository_url" {}

variable "privileged" {
  default = "false"
}

variable "command_array" {
  type    = "list"
  default = []
}

variable "environment_variables" {
  type    = "list"
  default = []
}
