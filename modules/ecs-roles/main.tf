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
      "ecs:DescribeServices",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:ListTaskDefinitions",
      "ecs:RegisterTaskDefinition",
      "ecs:StartTask",
      "ecs:StopTask",
      "ecs:UpdateService",
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
      "iam:PassRole",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::maersk-*",
      "arn:aws:s3:::maersk-*/*",
      "arn:aws:s3:::svc.mg.*",
      "arn:aws:s3:::svc.mg.*/*",
      "arn:aws:s3:::fsct-*",
      "arn:aws:s3:::fsct-*/*",
    ]
  }

  statement {
    actions = [
      "dynamodb:*",
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

  statement {
    sid = "DynamoDBreadonly"

    actions = [
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingActivities",
      "application-autoscaling:DescribeScalingPolicies",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "datapipeline:DescribeObjects",
      "datapipeline:DescribePipelines",
      "datapipeline:GetPipelineDefinition",
      "datapipeline:ListPipelines",
      "datapipeline:QueryObjects",
      "dynamodb:BatchGetItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:ListTables",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:DescribeLimits",
      "dynamodb:ListGlobalTables",
      "dynamodb:DescribeGlobalTable",
      "dynamodb:DescribeBackup",
      "dynamodb:ListBackups",
      "dynamodb:DescribeContinuousBackups",
      "dax:Describe*",
      "dax:List*",
      "dax:GetItem",
      "dax:BatchGetItem",
      "dax:Query",
      "dax:Scan",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "iam:GetRole",
      "iam:ListRoles",
      "sns:ListSubscriptionsByTopic",
      "sns:ListTopics",
      "lambda:ListFunctions",
      "lambda:ListEventSourceMappings",
      "lambda:GetFunctionConfiguration",
    ]

    resources = ["*"]
  }
}

# Creating necessary roles
resource "aws_iam_role" "ecs_execution_role" {
  name_prefix = "${var.name_prefix}"
  path        = "/"
  description = "Role needed to execute ECS tasks"

  assume_role_policy = "${data.aws_iam_policy_document.ecs_execution_role.json}"
}

resource "aws_iam_role" "ec2_ecs_role" {
  name_prefix = "${var.name_prefix}"
  path        = "/"
  description = "Policy for ec2_ecs_role"

  assume_role_policy = "${data.aws_iam_policy_document.ec2_ecs_role.json}"
}

resource "aws_iam_policy" "ecs_execution" {
  name_prefix = "${var.name_prefix}"
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
