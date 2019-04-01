variable "name_prefix" {
  description = "Solution name"
}

variable "tags" {
  description = "Additional tags (e.g. `map('Project', 'ABC')`"
  type        = "map"
}

variable "job_vcpus" {
  description = "The number of vCPUs reserved for the container."
}

variable "job_memory" {
  description = "The hard limit (in MiB) of memory to present to the container."
}

variable "worker_instance_type" {
  description = "Instance types that may be launched"
}

variable "subnet" {
  description = "VPC subnets into which the compute resources are launched"
}

variable "security_group" {
  description = "A list of EC2 security group that are associated with instances launched in the compute environment."
}

variable "job_policy_document" {
  description = "Job definitions policy"
}

variable "repository_url" {
  description = "The image used to start a container."
}

variable "privileged" {
  description = "When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user)"
  default     = "false"
}

variable "command_array" {
  description = "The command that is passed to the container"
  type        = "list"
}

variable "environment_variables" {
  description = "The environment variables to pass to a container"
  type        = "list"
}
