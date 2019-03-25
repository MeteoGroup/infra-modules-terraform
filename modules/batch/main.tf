data "aws_iam_policy_document" "instance_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "batch_instance" {
  assume_role_policy = "${data.aws_iam_policy_document.instance_assume_role.json}"
  name               = "${var.name_prefix}-batch-instance"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role       = "${aws_iam_role.batch_instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "batch_instance" {
  name = "${var.name_prefix}-batch-instance"
  role = "${aws_iam_role.batch_instance.name}"
}

data "aws_iam_policy_document" "batch_service" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "batch_service" {
  assume_role_policy = "${data.aws_iam_policy_document.batch_service.json}"
  name               = "${var.name_prefix}-batch-service"
}

resource "aws_iam_role_policy_attachment" "batch_service" {
  role       = "${aws_iam_role.batch_service.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

data "aws_iam_policy_document" "monitoring_policy" {
  statement {
    actions = [
      "cloudwatch:*",
      "logs:*",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "monitoring_policy" {
  name   = "monitoring"
  policy = "${data.aws_iam_policy_document.monitoring_policy.json}"
  role   = "${aws_iam_role.batch_instance.id}"
}

data "aws_iam_policy_document" "tagging_policy" {
  statement {
    actions   = ["ec2:CreateTags"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "tagging_policy" {
  name   = "tagging"
  policy = "${data.aws_iam_policy_document.tagging_policy.json}"
  role   = "${aws_iam_role.batch_instance.id}"
}

data "aws_iam_policy_document" "ecs_policy" {
  statement {
    actions = [
      "ecs:Submit*",
      "ecs:StartTelemetrySession",
      "ecs:StartTask",
      "ecs:RegisterContainerInstance",
      "ecs:Poll",
      "ecs:DiscoverPollEndpoint",
      "ecs:DeregisterContainerInstance",
      "ecs:CreateCluster",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_policy" {
  name   = "ecs"
  policy = "${data.aws_iam_policy_document.ecs_policy.json}"
  role   = "${aws_iam_role.batch_instance.id}"
}

resource "aws_batch_compute_environment" "this" {
  compute_environment_name = "${var.name_prefix}"

  service_role = "${aws_iam_role.batch_service.arn}"
  type         = "UNMANAGED"

  depends_on = [
    "aws_iam_role_policy_attachment.batch_service",
    "aws_iam_role_policy_attachment.ecs_instance_role",
  ]

  lifecycle {
    create_before_destroy = true
  }
}


data "aws_ami" "ecs_optimized_latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

locals {
  instance_user_data = <<SCRIPT
#!/bin/bash
echo ECS_CLUSTER=${aws_batch_compute_environment.this.ecs_cluster_arn} >> /etc/ecs/ecs.config
SCRIPT
}

resource "aws_launch_template" "this" {
  name = "${var.name_prefix}"

  iam_instance_profile {
    name = "${aws_iam_instance_profile.batch_instance.name}"
  }

  image_id = "${data.aws_ami.ecs_optimized_latest.image_id}"

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "${var.worker_instance_type}"

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination = true
    security_groups = ["${var.security_group}"]
    subnet_id = "${var.subnet}"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = "${var.tags}"
  }
  tag_specifications {
    resource_type = "volume"
    tags          = "${var.tags}"
  }

  user_data = "${base64encode(local.instance_user_data)}"
}


data "aws_iam_policy_document" "job_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "job" {
  assume_role_policy = "${data.aws_iam_policy_document.job_assume_role.json}"
  name               = "${var.name_prefix}-batch-job"
}

resource "aws_iam_role_policy" "job_main" {
  name   = "main"
  policy = "${var.job_policy_document}"
  role   = "${aws_iam_role.job.id}"
}


locals {
  container_properties = {
    command = [
      "python",
      "-m",
      "app.main",
      "Ref::event"
    ],
    image = "${var.repository_url}:latest",
    jobRoleArn = "${aws_iam_role.job.arn}",
    vcpus = "${var.job_vcpus}",
    memory = "${var.job_memory}",
    environment = "${var.environment_variables}",
    volumes = [
      {
        host = {
          sourcePath = "/tmp"
        },
        name = "tmp"
      }
    ],
    mountPoints = [
      {
        sourceVolume = "tmp",
        containerPath = "/tmp"
      }
    ]
  }
}

resource "aws_batch_job_definition" "this" {
  name = "${var.name_prefix}"
  type = "container"

  retry_strategy = {
    attempts = 2
  }

  timeout = {
    # 55min - so jobs are usually killed before next issue starts
    attempt_duration_seconds = 3300
  }

  # replace(replace(...)) as workaround for terraform bug,
  # as per https://github.com/hashicorp/terraform/issues/17033#issuecomment-399908596
  container_properties = "${replace(replace(jsonencode(local.container_properties),
                                            "/\"([0-9]+\\.?[0-9]*)\"/",
                                            "$1"),
                                    "string:",
                                    "")}"
}


resource "aws_batch_job_queue" "main_queue" {
  name     = "${var.name_prefix}"
  state    = "ENABLED"
  priority = 1

  compute_environments = ["${aws_batch_compute_environment.this.arn}"]
}
