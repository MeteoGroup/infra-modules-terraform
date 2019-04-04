resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id       = "${var.api_id}"
  stage_name        = "${var.stage_name}"
  description       = "${var.deployment_description}"
  stage_description = "${var.stage_description}"
}

resource "aws_api_gateway_method_settings" "settings" {
  depends_on  = ["aws_api_gateway_deployment.deployment"]
  rest_api_id = "${var.api_id}"
  stage_name  = "${var.stage_name}"
  method_path = "*/*"

  settings {
    metrics_enabled        = "${var.metrics_enabled}"
    logging_level          = "${var.logging_level}"
    data_trace_enabled     = "${var.data_trace_enabled}"
    throttling_burst_limit = "${var.throttling_burst_limit}"
    throttling_rate_limit  = "${var.throttling_rate_limit}"
    caching_enabled        = "false"
  }
}
