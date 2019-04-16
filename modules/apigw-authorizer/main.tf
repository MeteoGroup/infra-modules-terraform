resource "aws_api_gateway_authorizer" "authorizer" {
  name                   = "${var.authorizer_name}"
  rest_api_id            = "${var.api_id}"
  authorizer_credentials = "${aws_iam_role.invocation_role.arn}"

  authorizer_uri                   = "${aws_lambda_function.authorizer.invoke_arn}"
  type                             = "TOKEN"
  identity_validation_expression   = "Bearer\\s(\\S+)"
  authorizer_result_ttl_in_seconds = 300
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
    actions   = ["lambda:InvokeFunction"]
    resources = ["${aws_lambda_function.authorizer.arn}"]
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/lambda/${aws_lambda_function.authorizer.function_name}"
  retention_in_days = "${var.cloudwatch_log_group_retention_in_days}"
}

resource "aws_lambda_function" "authorizer" {
  s3_bucket     = "${var.bucket}"
  s3_key        = "${var.key}"
  function_name = "${var.function_name}"
  role          = "${aws_iam_role.role.arn}"
  handler       = "${var.handler}"

  runtime     = "dotnetcore2.1"
  memory_size = "${var.memory_size}"
  timeout     = "${var.timeout}"
  tags        = "${var.tags}"

  source_code_hash = ""

  environment {
    variables = "${var.environment_variables}"
  }

  lifecycle {
    ignore_changes = ["last_modified"]
  }
}

resource "aws_iam_role" "role" {
  assume_role_policy = "${data.aws_iam_policy_document.assume_lambda.json}"
  description        = "Authorizer resource access"
  name               = "${var.authorizer_name}-${var.environment}-lambda"
  path               = "${var.lambda_role_path}"
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  count      = "${length(var.lambda_role_policy_arns)}"
  policy_arn = "${element(var.lambda_role_policy_arns, count.index)}"
  role       = "${aws_iam_role.role.name}"
}

resource "aws_iam_role_policy" "role_policy" {
  name   = "${var.authorizer_name}-${var.environment}"
  policy = "${data.aws_iam_policy_document.role.json}"
  role   = "${aws_iam_role.role.id}"
}

resource "aws_iam_role" "invocation_role" {
  name               = "${var.authorizer_name}-api-gateway-auth-invocation"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.assume_lambda}"

  #  assume_role_policy = <<EOF
  #{
  #  "Version": "2012-10-17",
  #  "Statement": [
  #    {
  #      "Action": "sts:AssumeRole",
  #      "Principal": {
  #        "Service": "apigateway.amazonaws.com"
  #      },
  #      "Effect": "Allow",
  #      "Sid": ""
  #    }
  #  ]
  #}
  #EOF
}

resource "aws_iam_role_policy" "invocation_policy" {
  name   = "${var.authorizer_name}-invocation-policy"
  role   = "${aws_iam_role.invocation_role.id}"
  policy = "${data.aws_iam_policy_document.role.json}"

  #  policy = <<EOF
  #{
  #  "Version": "2012-10-17",
  #  "Statement": [
  #    {
  #      "Action": "lambda:InvokeFunction",
  #      "Effect": "Allow",
  #      "Resource": "${aws_lambda_function.authorizer.arn}"
  #    }
  #  ]
  #}
  #EOF
}
