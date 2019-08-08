data "aws_region" "default" {}

data "aws_lambda_function" "lambda_auth" {
  function_name = "${var.function_name}"
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name                   = "${var.authorizer_name}"
  rest_api_id            = "${var.api_id}"
  authorizer_credentials = "${aws_iam_role.invocation_role.arn}"

  authorizer_uri                   = "arn:aws:apigateway:${data.aws_region.default.name}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.lambda_auth.arn}:${upper("${var.environment}")}/invocations"
  type                             = "TOKEN"
  identity_validation_expression   = "Bearer\\s(\\S+)"
  authorizer_result_ttl_in_seconds = "${var.cache_ttl}"
}

data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "apigateway.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "role" {
  statement {
    actions = ["lambda:InvokeFunction"]

    resources = [
      "${data.aws_lambda_function.lambda_auth.arn}",
      "${data.aws_lambda_function.lambda_auth.arn}:*",
    ]
  }
}

resource "aws_iam_role" "invocation_role" {
  name_prefix        = "${var.environment}"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.assume_lambda.json}"
}

resource "aws_iam_role_policy" "invocation_policy" {
  name_prefix = "${var.environment}"
  role        = "${aws_iam_role.invocation_role.id}"
  policy      = "${data.aws_iam_policy_document.role.json}"
}
