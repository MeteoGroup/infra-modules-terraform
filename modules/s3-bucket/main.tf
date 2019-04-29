data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

locals {
  enable_sns_topic         = "${var.enabled && var.sns_topic}"
  enable_readonly_accounts = "${var.enabled && length(var.readonly_accounts) > 0}"
  enable_logs_bucket       = "${var.enabled && var.enable_put_logs && length(var.log_location_prefix) > 0}"
}

resource "aws_s3_bucket" "default" {
  count = "${var.enabled ? 1 : 0}"

  bucket = "${var.name}"
  region = "${var.region}"
  tags   = "${var.tags}"

  versioning {
    enabled = "${var.versioning}"
  }

  force_destroy = true
  request_payer = "BucketOwner"

  lifecycle_rule = "${var.lifecycle_rules}"
}

data "aws_iam_policy_document" "bucket_policy" {
  count = "${local.enable_readonly_accounts ? 1 : 0}"

  statement {
    sid = "read"

    resources = [
      "${aws_s3_bucket.default.arn}",
      "${aws_s3_bucket.default.arn}/*",
    ]

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    principals {
      type        = "AWS"
      identifiers = "${var.readonly_accounts}"
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  count = "${local.enable_readonly_accounts ? 1 : 0}"

  bucket = "${aws_s3_bucket.default.id}"
  policy = "${data.aws_iam_policy_document.bucket_policy.json}"
}

data "aws_iam_policy_document" "log_bucket_policy" {
  count = "${local.enable_logs_bucket ? 1 : 0}"

  statement {
    sid       = "allow_put"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.default.id}/${var.log_location_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.main.id}:root"]
    }
  }
}

resource "aws_s3_bucket_policy" "logs_bucket" {
  count = "${local.enable_logs_bucket ? 1 : 0}"

  bucket = "${aws_s3_bucket.default.id}"
  policy = "${data.aws_iam_policy_document.log_bucket_policy.json}"
}

resource "aws_sns_topic" "default" {
  count = "${local.enable_sns_topic ? 1 : 0}"

  display_name = "${var.name}-sns"
}

data "aws_iam_policy_document" "sns_policy_base" {
  count = "${local.enable_sns_topic ? 1 : 0}"

  statement {
    sid       = "publish"
    resources = ["${aws_sns_topic.default.arn}"]
    actions   = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = ["${aws_s3_bucket.default.arn}"]
    }
  }
}

data "aws_iam_policy_document" "sns_policy_cross_account" {
  count       = "${local.enable_sns_topic && local.enable_readonly_accounts ? 1 : 0}"
  source_json = "${data.aws_iam_policy_document.sns_policy_base.json}"

  statement {
    sid       = "subscribe"
    resources = ["${aws_sns_topic.default.arn}"]

    actions = [
      "sns:Subscribe",
      "sns:GetTopicAttributes",
      "sns:ListSubscriptionsByTopic",
    ]

    principals {
      type        = "AWS"
      identifiers = "${var.readonly_accounts}"
    }
  }
}

resource "aws_sns_topic_policy" "base" {
  count  = "${local.enable_sns_topic && ! local.enable_readonly_accounts ? 1 : 0}"
  arn    = "${aws_sns_topic.default.arn}"
  policy = "${data.aws_iam_policy_document.sns_policy_base.json}"
}

resource "aws_sns_topic_policy" "cross_account" {
  count  = "${local.enable_sns_topic && local.enable_readonly_accounts ? 1 : 0}"
  arn    = "${aws_sns_topic.default.arn}"
  policy = "${data.aws_iam_policy_document.sns_policy_cross_account.json}"
}

resource "aws_s3_bucket_notification" "default" {
  count  = "${local.enable_sns_topic ? 1 : 0}"
  bucket = "${aws_s3_bucket.default.id}"

  topic {
    id        = "${aws_sns_topic.default.name}"
    topic_arn = "${aws_sns_topic.default.arn}"
    events    = ["s3:ObjectCreated:*"]
  }
}
