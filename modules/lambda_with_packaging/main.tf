data "aws_iam_policy_document" "trust" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${var.source_dir}"
  output_path = ".terraform/${var.source_prefix}.zip"
}

resource "aws_s3_bucket_object" "lambda_zip" {
  bucket = "${var.source_bucket}"
  key    = "${var.source_prefix}.zip"
  source = "${data.archive_file.lambda_zip.output_path}"
  etag   = "${filemd5(data.archive_file.lambda_zip.output_path)}"
}

resource "aws_lambda_function" "this" {
  s3_bucket        = "${var.source_bucket}"
  s3_key           = "${aws_s3_bucket_object.lambda_zip.id}"
  function_name    = "${var.function_name}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "${var.handler}"
  runtime          = "${var.runtime}"
  timeout          = "${var.timeout}"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"

  environment {
    variables = "${var.environment_variables}"
  }
}

resource "aws_lambda_permission" "allow_source" {
  function_name = "${aws_lambda_function.this.function_name}"

  statement_id = "AllowExecutionFrom${count.index}"
  action       = "lambda:InvokeFunction"
  principal    = "${var.source_types[count.index]}.amazonaws.com"
  source_arn   = "${var.source_arns[count.index]}"
  count        = "${length(var.source_types)}"
}

resource "aws_iam_role_policy" "lambda_perms" {
  name   = "lambda_perms"
  role   = "${aws_iam_role.lambda.name}"
  policy = "${var.access_policy_document}"
}

resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}"
  assume_role_policy = "${data.aws_iam_policy_document.trust.json}"
}
