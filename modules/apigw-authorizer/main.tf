resource "aws_api_gateway_authorizer" "authorizer" {
  name                   = "${var.authorizer_name}"
  rest_api_id            = "${var.api_id}"
  authorizer_credentials = "${aws_iam_role.invoke.arn}"

  # authorizer_uri                   = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
  authorizer_uri                   = "${aws_lambda_function.lambda.invoke_arn}"
  type                             = "TOKEN"
  identity_validation_expression   = "Bearer\\s(\\S+)"
  authorizer_result_ttl_in_seconds = 300
}

# The action this permission allows is to invoke the function
#resource "aws_lambda_permission" "allow_api_gateway" {
#  action        = "lambda:InvokeFunction"
#  function_name = "${aws_lambda_function.lambda.arn}"
#  statement_id  = "AllowAPIInvoke"
#  principal     = "apigateway.amazonaws.com"
#
#  # /*/*/* sets this permission for all stages, methods, and resource paths in API Gateway to the lambda function
#  #source_arn = "${var.api_execution_arn}/*/*/*"
#  # provides execution arn from stage module
#  source_arn = "${var.api_execution_arn}/*/*"
#}

data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "apigateway.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "assume_apigateway" {
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

data "aws_iam_policy_document" "invoke" {
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = ["${aws_lambda_function.lambda.arn}"]
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = "${var.cloudwatch_log_group_retention_in_days}"
}

resource "aws_lambda_function" "lambda" {
  s3_bucket     = "${var.bucket}"
  s3_key        = "${var.key}"
  function_name = "${var.function_name}"
  role          = "${aws_iam_role.lambda.arn}"
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

resource "aws_iam_role" "lambda" {
  assume_role_policy = "${data.aws_iam_policy_document.assume_lambda.json}"
  description        = "Authorizer resource access"
  name               = "${var.authorizer_name}-${var.environment}-lambda"
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  count      = "${length(var.lambda_role_policy_arns)}"
  policy_arn = "${element(var.lambda_role_policy_arns, count.index)}"
  role       = "${aws_iam_role.lambda.name}"
}

resource "aws_iam_role" "invoke" {
  assume_role_policy = "${data.aws_iam_policy_document.assume_apigateway.json}"
  description        = "Invoke role"
  name               = "${var.authorizer_name}-${var.environment}-invoke"
  path               = "${var.lambda_role_path}"
}

resource "aws_iam_role_policy" "invoke_policy" {
  name   = "${var.authorizer_name}-${var.environment}"
  policy = "${data.aws_iam_policy_document.invoke.json}"
  role   = "${aws_iam_role.invoke.id}"
}
