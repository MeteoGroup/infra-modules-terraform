variable "name_prefix" {}

variable "tags" {
  type = "map"
}

variable "job_vcpus" {}
variable "job_memory" {}

variable "worker_instance_type" {}

variable "subnet" {}
variable "security_group" {}

variable "job_policy_document" {}

variable "repository_url" {}

variable "privileged" {
  default = "false"
}

variable "command_array" {
  type = "list"
}

variable "environment_variables" {
  type = "list"
}
