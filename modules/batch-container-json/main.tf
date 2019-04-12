# Environment variables are composed into the container definition at output generation time. See outputs.tf for more information.
locals {
  container_properties = {
    command                = "${var.command}"
    image                  = "${var.container_image}"
    jobRoleArn             = "${var.job_iam_role}"
    vcpus                  = "${var.container_cpu}"
    memory                 = "${var.container_memory}"
    readonlyRootFilesystem = "${var.readonly_root_filesystem}"

    volumes = "${var.volumes}"

    mountPoints = "${var.mount_points}"

    environment = "environment_sentinel_value"
  }

  environment = "${var.environment}"
}
