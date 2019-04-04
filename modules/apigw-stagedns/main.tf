#####https://github.com/terraform-providers/terraform-provider-aws/issues/162
#### Stage is not redployed, workaround has to be provided
locals {
  stage_name             = "${var.name_prefix}-${var.stage}"
  stage_description      = "Stage ${var.stage}"
  deployment_description = "Description of stage ${var.stage}"
}

module "api_deployment" {
  source = "../apigw-deployment"

  api_id = "${var.api_id}"

  stage_name             = "${local.stage_name}"
  stage_description      = "${local.stage_description}"
  deployment_description = "${local.deployment_description}"
  metrics_enabled        = true
  logging_level          = "INFO"
  data_trace_enabled     = true
  throttling_rate_limit  = "5000"
  throttling_burst_limit = "10000"
}

resource "aws_api_gateway_domain_name" "api_domain" {
  domain_name = "${var.api_name}.${var.dns_zone_name}"

  regional_certificate_arn = "${var.certificate_arn}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "api_gateway" {
  zone_id = "${var.route53_zone_id}"

  name = "${aws_api_gateway_domain_name.api_domain.domain_name}"
  type = "A"

  alias {
    name                   = "${aws_api_gateway_domain_name.api_domain.regional_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.api_domain.regional_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_api_gateway_base_path_mapping" "stage_dns_mapping" {
  api_id     = "${var.api_id}"
  stage_name = "${module.api_deployment.deployment_stage_name}"

  domain_name = "${aws_api_gateway_domain_name.api_domain.domain_name}"
}

data "aws_iam_policy_document" "api_gateway_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_gateway_role" {
  name        = "${local.stage_name}"
  path        = "/"
  description = "Role needed to log messages from API Gateway"

  assume_role_policy = "${data.aws_iam_policy_document.api_gateway_role.json}"
}

resource "aws_iam_role_policy_attachment" "api_gateway_role" {
  role       = "${aws_iam_role.api_gateway_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
