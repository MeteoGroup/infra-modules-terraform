# Environment variables are composed into the container definition at output generation time. See outputs.tf for more information.
locals {
  container_definition = {
    name                   = "${var.container_name}"
    image                  = "${var.container_image}"
    memory                 = "${var.container_memory}"
    memoryReservation      = "${var.container_memory_reservation}"
    cpu                    = "${var.container_cpu}"
    essential              = "${var.essential}"
    entryPoint             = "${var.entrypoint}"
    user                   = "${var.user}"
    command                = "${var.command}"
    workingDirectory       = "${var.working_directory}"
    readonlyRootFilesystem = "${var.readonly_root_filesystem}"

    portMappings = "${var.port_mappings}"

    ulimits = "${var.ulimits}"

    mountPoints = "${var.mount_points}"

    healthCheck = "${var.healthcheck}"

    logConfiguration = {
      logDriver = "${var.log_driver}"
      options   = "${var.log_options}"
    }

    environment = "environment_sentinel_value"
  }

  environment = "${var.environment}"
}
