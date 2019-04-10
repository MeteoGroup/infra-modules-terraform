# Assuming roles and creating policy documents
data "aws_iam_policy_document" "ec2_ecs_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_execution_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_execution" {
  statement {
    sid = "ECSservice"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
      "dynamodb:*",
    ]

    resources = ["*"]
  }

  statement {
    sid = "S3readonly"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = ["*"]
  }

  statement {
    sid = "SQSpermissions"

    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:ChangeMessageVisibilityBatch",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes",
    ]

    resources = ["*"]
  }
}

# Creating necessary roles
resource "aws_iam_role" "ecs_execution_role" {
  name        = "${var.name_prefix}-ecs-execution-role"
  path        = "/"
  description = "Role needed to execute ECS tasks"

  assume_role_policy = "${data.aws_iam_policy_document.ecs_execution_role.json}"
}

resource "aws_iam_role" "ec2_ecs_role" {
  name        = "${var.name_prefix}-ec2-ecs-role"
  path        = "/"
  description = "Policy for ec2_ecs_role"

  assume_role_policy = "${data.aws_iam_policy_document.ec2_ecs_role.json}"
}

resource "aws_iam_policy" "ecs_execution" {
  name        = "${var.name_prefix}-ecs-task-policies"
  path        = "/"
  description = "Role needed to execute ECS tasks"

  policy = "${data.aws_iam_policy_document.ecs_execution.json}"
}

# Attaching policies to roles
resource "aws_iam_role_policy_attachment" "ecs_execution_role" {
  role       = "${aws_iam_role.ecs_execution_role.name}"
  policy_arn = "${aws_iam_policy.ecs_execution.arn}"
}

resource "aws_iam_role_policy_attachment" "ec2_ecs_role" {
  role       = "${aws_iam_role.ec2_ecs_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
