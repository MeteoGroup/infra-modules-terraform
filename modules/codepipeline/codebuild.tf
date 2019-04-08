resource "aws_s3_bucket" "cache_bucket" {
  count         = "${var.cache_enabled == "true" ? 1 : 0}"
  bucket        = "${local.cache_bucket_name_normalised}"
  acl           = "private"
  force_destroy = true
  tags          = "${var.tags}"

  lifecycle_rule {
    id      = "codebuildcache"
    enabled = true

    prefix = "/"
    tags   = "${var.tags}"

    expiration {
      days = "${var.cache_expiration_days}"
    }
  }
}

resource "random_string" "bucket_prefix" {
  length  = 12
  number  = false
  upper   = false
  special = false
  lower   = true
}

locals {
  cache_bucket_name = "mg-${var.name_prefix}${var.cache_bucket_suffix_enabled == "true" ? "-${random_string.bucket_prefix.result}" : "" }"

  ## Clean up the bucket name to use only hyphens, and trim its length to 63 characters.
  ## As per https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html
  cache_bucket_name_normalised = "${substr(join("-", split("_", lower(local.cache_bucket_name))), 0, min(length(local.cache_bucket_name),63))}"

  ## This is the magic where a map of a list of maps is generated
  ## and used to conditionally add the cache bucket option to the
  ## aws_codebuild_project
  cache_def = {
    "true" = [{
      type     = "S3"
      location = "${var.cache_enabled == "true" ? join("", aws_s3_bucket.cache_bucket.*.bucket) : "none" }"
    }]

    "false" = []
  }

  # Final Map Selected from above
  cache = "${local.cache_def[var.cache_enabled]}"
}

resource "aws_iam_role" "assume_codebuild" {
  name               = "${var.name_prefix}-code"
  assume_role_policy = "${data.aws_iam_policy_document.service_codebuild.json}"
}

data "aws_iam_policy_document" "service_codebuild" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_policy" "permissions" {
  name   = "${var.name_prefix}-code"
  path   = "/service-role/"
  policy = "${data.aws_iam_policy_document.permissions.json}"
}

resource "aws_iam_policy" "infra_nonprod" {
  count  = "${var.infra_build == "true" ? 1 : 0}"
  name   = "${var.name_prefix}-infra"
  path   = "/service-role/"
  policy = "${data.aws_iam_policy_document.infra_nonprod.json}"
}

resource "aws_iam_policy" "permissions_cache_bucket" {
  count  = "${var.cache_enabled == "true" ? 1 : 0}"
  name   = "${var.name_prefix}-cache-bucket"
  path   = "/service-role/"
  policy = "${data.aws_iam_policy_document.permissions_cache_bucket.json}"
}

data "aws_iam_policy_document" "permissions" {
  # Original statement
  statement {
    sid = ""

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecs:RunTask",
      "iam:PassRole",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ssm:GetParameters",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }

  statement {
    sid = ""

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.default.account_id}:root"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "infra_nonprod" {
  # DynamoDB
  statement {
    actions   = ["dynamodb:*"]
    resources = ["arn:aws:dynamodb:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:table/maersk-*"]
  }

  # S3
  statement {
    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::mg-maersk-*",
      "arn:aws:s3:::mg-maersk-*/*",
      "arn:aws:s3:::svc.mg.*",
      "arn:aws:s3:::svc.mg.*/*",
    ]
  }

  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::*"]
  }

  # EC2
  statement {
    actions = [
      "ec2:*",
      "sns:ListSubscriptions",
      "sns:ListTopics",
      "sns:Publish",
      "logs:DescribeLogGroups",
      "logs:ListTagsLogGroup",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "ecr:CreateRepository",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "lambda:CreateEventSourceMapping",
      "lambda:GetEventSourceMapping",
      "lambda:DeleteEventSourceMapping",
      "lambda:UpdateEventSourceMapping",
      "ecs:Describe*",
      "ecs:Create*",
      "ecs:Update*",
      "ecs:Delete*",
      "ecs:List*",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "acm:RequestCertificate",
      "acm:AddTagsToCertificate",
      "acm:ListTagsForCertificate",
      "acm:DeleteCertificate",
      "route53:CreateHostedZone",
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListHealthChecks",
      "route53:ListResourceRecordSets",
      "route53:ChangeTagsForResource",
      "elasticfilesystem:Create*",
      "elasticfilesystem:Delete*",
      "elasticfilesystem:Describe*",
      "elasticloadbalancing:Register*",
      "elasticloadbalancing:Deregister*",
      "elasticloadbalancing:Create*",
      "elasticloadbalancing:Add*",
      "elasticloadbalancing:Delete*",
      "elasticloadbalancing:Modify*",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:Set*",
      "autoscaling:*",
      "application-autoscaling:DeleteScalingPolicy",
      "application-autoscaling:DeregisterScalableTarget",
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingActivities",
      "application-autoscaling:DescribeScalingPolicies",
      "application-autoscaling:PutScalingPolicy",
      "application-autoscaling:RegisterScalableTarget",
      "kms:DescribeKey",
      "kms:ListAliases",
      "rds:*",
      "sqs:*",
      "cloudfront:*",
      "iam:ListServerCertificates",
      "waf:ListWebACLs",
      "waf:GetWebACL",
    ]

    resources = ["*"]
  }

  # IAM
  statement {
    actions = ["iam:*"]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.default.account_id}:role/maersk-*",
      "arn:aws:iam::${data.aws_caller_identity.default.account_id}:policy/maersk-*",
      "arn:aws:iam::${data.aws_caller_identity.default.account_id}:instance-profile/maersk-*",
      "arn:aws:iam::${data.aws_caller_identity.default.account_id}:role/terraform-*",
      "arn:aws:iam::${data.aws_caller_identity.default.account_id}:policy/terraform-*",
      "arn:aws:iam::${data.aws_caller_identity.default.account_id}:instance-profile/terraform-*",
    ]
  }

  statement {
    actions = [
      "iam:PassRole",
      "iam:CreateServiceLinkedRole",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.default.account_id}:role/ecsTaskExecutionRole",
      "arn:aws:iam::${data.aws_caller_identity.default.account_id}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService",
      "arn:aws:iam::${data.aws_caller_identity.default.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
      "arn:aws:iam::${data.aws_caller_identity.default.account_id}:role/aws-service-role/ops.apigateway.amazonaws.com/AWSServiceRoleForAPIGateway",
      "arn:aws:iam::${data.aws_caller_identity.default.account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing",
    ]
  }

  # SNS
  #statement {
  #  actions   = ["sns:*"]
  #  resources = ["arn:aws:sns:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:maersk-*"]
  #}


  #statement {
  #  actions = [
  #    "sns:Subscribe",
  #    "sns:GetSubscriptionAttributes",
  #    "sns:Unsubscribe",
  #  ]


  #  resources = [
  #    "arn:aws:sns:${data.aws_region.default.name}:${local.data_account_id}:terraform-*",
  #  ]
  #}

  # CloudWatch - Events
  statement {
    actions   = ["events:*"]
    resources = ["arn:aws:events:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:rule/maersk-*"]
  }
  # CloudWatch - Logs
  statement {
    actions   = ["logs:*"]
    resources = ["arn:aws:logs:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:log-group:/ecs/maersk-*"]
    resources = ["arn:aws:logs:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:log-group:/aws/lambda/maersk-*"]
  }
  statement {
    actions   = ["ecr:*"]
    resources = ["arn:aws:ecr:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:repository/maersk-*"]
  }
  # Lambda
  statement {
    actions   = ["lambda:*"]
    resources = ["arn:aws:lambda:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:function:maersk-*"]
  }
  # Route53
  statement = {
    actions = [
      "route53:GetHostedZone",
      "route53:GetChange",
    ]

    resources = ["arn:aws:route53:::change/*"]
  }
  statement = {
    sid = "AllowPublicHostedZonePermissionsCodebuild"

    actions = [
      "route53:CreateHealthCheck",
      "route53:UpdateHealthCheck",
      "route53:GetHealthCheck",
      "route53:ListHealthChecks",
      "route53:DeleteHealthCheck",
      "route53:GetCheckerIpRanges",
      "route53:GetHealthCheckCount",
      "route53:GetHealthCheckStatus",
      "route53:GetHealthCheckLastFailureReason",
      "route53:UpdateHostedZoneComment",
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:GetHostedZoneCount",
      "route53:ListHostedZonesByName",
      "route53:ListTagsForResource",
      "route53:DeleteHostedZone",
    ]

    resources = [
      "arn:aws:route53:::hostedzone/*",
    ]
  }
  statement = {
    actions = [
      "kms:*",
    ]

    resources = ["arn:aws:kms:eu-west-1:565092874728:key/01c12b58-7522-4d20-8631-a83290be6a0c"]
  }
  # PI
  statement = {
    actions = [
      "pi:*",
    ]

    resources = [
      "arn:aws:pi:*:*:metrics/rds/*",
    ]
  }
  # API Gateway
  statement = {
    actions = [
      "apigateway:*",
    ]

    resources = [
      "arn:aws:apigateway:*::/*",
      "arn:aws:apigateway:*::/restapis",
    ]
  }
}

data "aws_iam_policy_document" "permissions_cache_bucket" {
  statement {
    sid = ""

    actions = [
      "s3:*",
    ]

    effect = "Allow"

    resources = [
      "${aws_s3_bucket.cache_bucket.arn}",
      "${aws_s3_bucket.cache_bucket.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "permissions" {
  policy_arn = "${aws_iam_policy.permissions.arn}"
  role       = "${aws_iam_role.assume_codebuild.id}"
}

resource "aws_iam_role_policy_attachment" "infra_nonprod" {
  count      = "${var.infra_build == "true" ? 1 : 0}"
  policy_arn = "${aws_iam_policy.infra_nonprod.arn}"
  role       = "${aws_iam_role.assume_codebuild.id}"
}

resource "aws_iam_role_policy_attachment" "default_cache_bucket" {
  count      = "${var.cache_enabled == "true" ? 1 : 0}"
  policy_arn = "${element(aws_iam_policy.permissions_cache_bucket.*.arn, count.index)}"
  role       = "${aws_iam_role.assume_codebuild.id}"
}

resource "aws_codebuild_project" "default" {
  name          = "${var.name_prefix}"
  service_role  = "${aws_iam_role.assume_codebuild.arn}"
  badge_enabled = "${var.badge_enabled}"
  build_timeout = "${var.build_timeout}"

  artifacts {
    type = "${var.artifact_type}"
  }

  # The cache as a list with a map object inside.
  cache = ["${local.cache}"]

  environment {
    compute_type                = "${var.build_compute_type}"
    image                       = "${var.build_image}"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = "${var.privileged_mode}"
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable = [{
      "name"  = "AWS_REGION"
      "value" = "${signum(length(var.aws_region)) == 1 ? var.aws_region : data.aws_region.default.name}"
    },
      {
        "name"  = "AWS_ACCOUNT_ID"
        "value" = "${signum(length(var.aws_account_id)) == 1 ? var.aws_account_id : data.aws_caller_identity.default.account_id}"
      },
      {
        "name"  = "IMAGE_REPO_NAME"
        "value" = "${signum(length(var.image_repo_name)) == 1 ? var.image_repo_name : "UNSET"}"
      },
      {
        "name"  = "IMAGE_TAG"
        "value" = "${signum(length(var.image_tag)) == 1 ? var.image_tag : "latest"}"
      },
      {
        "name"  = "STAGE"
        "value" = "${signum(length(var.stage)) == 1 ? var.stage : "UNSET"}"
      },
      {
        "name"  = "GITHUB_TOKEN"
        "value" = "${signum(length(var.github_token)) == 1 ? var.github_token : "UNSET"}"
      },
      "${var.environment_variables}",
    ]
  }

  source {
    buildspec           = "${var.buildspec}"
    type                = "${var.source_type}"
    location            = "${var.source_location}"
    report_build_status = "${var.report_build_status}"
  }

  tags = "${var.tags}"
}
