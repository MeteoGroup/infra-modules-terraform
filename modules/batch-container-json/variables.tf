variable "container_image" {
  type        = "string"
  description = "The image used to start the container. Images in the Docker Hub registry available by default"
}

variable "volume_name" {
  type        = "string"
  description = "Name for the host volume"
}

variable "job_iam_role" {
  type        = "string"
  description = "Arn for a Role to use with batch job"
}

variable "container_memory" {
  description = "The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container_memory of all containers in a task will need to be lower than the task memory value"
  default     = 128
}

variable "volumes" {
  type        = "list"
  description = "The volumes to configure for the container. This is a list of maps. Each map should contain  \"host\" with \"sourcePath\" map, and \"name\" "

  default = [{}]
}

variable "host" {
  type        = "map"
  description = "Map for host volumes"

  default = {}
}

variable "mount_points" {
  type        = "list"
  description = "The mount points to configure for the container. This is a list of maps. Each map should contain \"containerPath\", \"sourceVolume\"."
  default     = [{}]
}

variable "container_cpu" {
  description = "The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value"
  default     = 1
}

variable "command" {
  type        = "list"
  description = "The command that is passed to the container"
  default     = [""]
}

variable "environment" {
  type        = "list"
  description = "The environment variables to pas to the container. This is a list of maps"
  default     = []
}

variable "readonly_root_filesystem" {
  type        = "string"
  description = "Determines whether a container is given read-only access to its root filesystem. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = "false"
}
