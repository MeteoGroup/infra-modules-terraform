data "aws_caller_identity" "default" {}

data "aws_region" "default" {}

#provider "github" {
#  version      = "~> 1.3"
#  token        = "${var.github_oauth_token}"
#  organization = "${var.repo_owner}"
#}

#resource "github_repository" "default" {
#  name        = "${var.repo_owner}/${var.repo_name}"
#  description = "GitHub Private repository"
#  private     = true
#}

resource "aws_s3_bucket" "default" {
  bucket        = "mg-${var.name_prefix}"
  force_destroy = true
  acl           = "private"
  tags          = "${var.tags}"
}

resource "aws_iam_role" "default" {
  name               = "${var.name_prefix}-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume.json}"
}

data "aws_iam_policy_document" "assume" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = "${aws_iam_role.default.id}"
  policy_arn = "${aws_iam_policy.default.arn}"
}

resource "aws_iam_policy" "default" {
  name   = "${var.name_prefix}-policy"
  policy = "${data.aws_iam_policy_document.default.json}"
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
      "iam:PassRole",
      "logs:PutRetentionPolicy",
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = "${aws_iam_role.default.id}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

resource "aws_iam_policy" "s3" {
  name   = "${var.name_prefix}-s3"
  policy = "${data.aws_iam_policy_document.s3.json}"
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid = ""

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
      "s3:List*",
    ]

    resources = [
      "${aws_s3_bucket.default.arn}",
      "${aws_s3_bucket.default.arn}/*",
      "arn:aws:s3:::elasticbeanstalk*",
      "arn:aws:s3:::mg-maersk-*",
      "arn:aws:s3:::mg-maersk-*/*",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = "${aws_iam_role.default.id}"
  policy_arn = "${aws_iam_policy.codebuild.arn}"
}

resource "aws_iam_policy" "codebuild" {
  name   = "${var.name_prefix}-build"
  policy = "${data.aws_iam_policy_document.codebuild.json}"
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    sid = ""

    actions = [
      "codebuild:*",
    ]

    resources = ["${aws_codebuild_project.default.id}"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "codebuild_s3" {
  role       = "${aws_codebuild_project.default.role_arn}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

# Only one of the `aws_codepipeline` resources below will be created:

# "source_build_deploy" will be created if `var.enabled` is set to `true` and the Elastic Beanstalk application name and environment name are specified

# This is used in two use-cases:

# 1. GitHub -> S3 -> Elastic Beanstalk (running application stack like Node, Go, Java, IIS, Python)

# 2. GitHub -> ECR (Docker image) -> Elastic Beanstalk (running Docker stack)

# "source_build" will be created if `var.enabled` is set to `true` and the Elastic Beanstalk application name or environment name are not specified

# This is used in this use-case:

# 1. GitHub -> ECR (Docker image)

resource "aws_codepipeline" "source_build_deploy" {
  # Elastic Beanstalk application name and environment name are specified
  count    = "${signum(length(var.app)) == 1 && signum(length(var.env)) == 1 ? 1 : 0}"
  name     = "${var.name_prefix}"
  role_arn = "${aws_iam_role.default.arn}"

  artifact_store {
    location = "${aws_s3_bucket.default.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration {
        OAuthToken           = "${var.github_oauth_token}"
        Owner                = "${var.repo_owner}"
        Repo                 = "${var.repo_name}"
        Branch               = "${var.branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["code"]
      output_artifacts = ["package"]

      configuration {
        ProjectName = "${aws_codebuild_project.default.name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      input_artifacts = ["package"]
      version         = "1"

      configuration {
        ApplicationName = "${var.app}"
        EnvironmentName = "${var.env}"
      }
    }
  }
}

resource "aws_codepipeline" "source_build" {
  # Elastic Beanstalk application name or environment name are not specified
  count    = "${(signum(length(var.app)) == 0 || signum(length(var.env)) == 0) ? 1 : 0}"
  name     = "${var.name_prefix}"
  role_arn = "${aws_iam_role.default.arn}"

  artifact_store {
    location = "${aws_s3_bucket.default.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration {
        OAuthToken           = "${var.github_oauth_token}"
        Owner                = "${var.repo_owner}"
        Repo                 = "${var.repo_name}"
        Branch               = "${var.branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["code"]
      output_artifacts = ["package"]

      configuration {
        ProjectName = "${aws_codebuild_project.default.name}"
      }
    }
  }
}

#data "aws_ssm_parameter" "webhook_secret" {
#  name = "/${var.name_prefix}/webhook-secret"
#}
#
#resource "aws_codepipeline_webhook" "source_build_deploy" {
#  count           = "${var.enabled && signum(length(var.app)) == 1 && signum(length(var.env)) == 1 ? 1 : 0}"
#  name            = "${var.name_prefix}-build-deploy"
#  authentication  = "GITHUB_HMAC"
#  target_action   = "Source"
#  target_pipeline = "${aws_codepipeline.source_build_deploy.name}"
#
#  authentication_configuration {
#    secret_token = "${data.aws_ssm_parameter.webhook_secret.value}"
#  }
#
#  filter {
#    json_path    = "$.ref"
#    match_equals = "refs/heads/{Branch}"
#  }
#}
#
#resource "github_repository_webhook" "source_build_deploy" {
#  count = "${var.enabled && signum(length(var.app)) == 1 && signum(length(var.env)) == 1 ? 1 : 0}"
#
#  #repository = "${github_repository.default.name}"
#  repository = "${var.repo_name}"
#  name       = "${var.name_prefix}-build-deploy"
#  active     = false
#
#  configuration {
#    url          = "${aws_codepipeline_webhook.source_build_deploy.url}"
#    content_type = "form"
#    insecure_ssl = false
#    secret       = "${data.aws_ssm_parameter.webhook_secret.value}"
#  }
#
#  events = ["push"]
#
#  lifecycle {
#    # This is required for idempotency
#    ignore_changes = ["configuration.secret"]
#  }
#}
#
#resource "aws_codepipeline_webhook" "source_build" {
#  count           = "${var.enabled && (signum(length(var.app)) == 0 || signum(length(var.env)) == 0) ? 1 : 0}"
#  name            = "${var.name_prefix}-source-build"
#  authentication  = "GITHUB_HMAC"
#  target_action   = "Source"
#  target_pipeline = "${aws_codepipeline.source_build.name}"
#
#  authentication_configuration {
#    secret_token = "${data.aws_ssm_parameter.webhook_secret.value}"
#  }
#
#  filter {
#    json_path    = "$.ref"
#    match_equals = "refs/heads/{Branch}"
#  }
#}
#
#resource "github_repository_webhook" "source_build" {
#  count = "${var.enabled && (signum(length(var.app)) == 0 || signum(length(var.env)) == 0) ? 1 : 0}"
#
#  #repository = "${github_repository.default.name}"
#  repository = "${var.repo_name}"
#  name       = "${var.name_prefix}-source-build"
#  active     = false
#
#  configuration {
#    url          = "${aws_codepipeline_webhook.source_build.url}"
#    content_type = "form"
#    insecure_ssl = false
#    secret       = "${data.aws_ssm_parameter.webhook_secret.value}"
#  }
#
#  events = ["push"]
#
#  lifecycle {
#    # This is required for idempotency
#    ignore_changes = ["configuration.secret"]
#  }
#}

