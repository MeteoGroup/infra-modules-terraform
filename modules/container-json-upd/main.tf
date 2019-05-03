# Environment variables are composed into the container definition at output generation time. See outputs.tf for more information.
locals {
  container_definition = {
    name                   = "${var.container_name}"
    image                  = "${var.container_image}"
    essential              = "${var.essential}"
    entryPoint             = "${var.entrypoint}"
    command                = "${var.command}"
    workingDirectory       = "${var.working_directory}"
    readonlyRootFilesystem = "${var.readonly_root_filesystem}"

    portMappings = "${var.port_mappings}"

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
