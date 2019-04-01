variable "name_prefix" {
  description = ""
}

variable "tags" {
  description = ""
  type        = "map"
}

variable "job_vcpus" {
  description = ""
}

variable "job_memory" {
  description = ""
}

variable "worker_instance_type" {
  description = ""
}

variable "subnet" {
  description = ""
}

variable "security_group" {
  description = ""
}

variable "job_policy_document" {
  description = ""
}

variable "repository_url" {
  description = ""
}

variable "privileged" {
  description = ""
  default     = "false"
}

variable "command_array" {
  description = ""
  type        = "list"
}

variable "environment_variables" {
  description = ""
  type        = "list"
}
