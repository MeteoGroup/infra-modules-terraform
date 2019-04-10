# resource
resource "aws_api_gateway_resource" "resource" {
  rest_api_id = "${var.api}"
  parent_id   = "${var.root_resource}"
  path_part   = "${var.resource}"
}

# resource methods
resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${var.api}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  authorization = "CUSTOM"
  authorizer_id = "${var.authorizer_id}"

  count       = "${var.num_methods}"
  http_method = "${lookup(var.methods[count.index], "method")}"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# backend resource
resource "aws_api_gateway_integration" "api_method_integration" {
  depends_on = ["aws_api_gateway_method.method"]

  rest_api_id = "${var.api}"
  resource_id = "${aws_api_gateway_resource.resource.id}"

  count                   = "${var.num_methods}"
  http_method             = "${lookup(var.methods[count.index], "method")}"
  integration_http_method = "${lookup(var.methods[count.index], "integration_method", "GET")}"
  uri                     = "${lookup(var.methods[count.index], "uri")}"
  type                    = "${lookup(var.methods[count.index], "type", "HTTP")}"

  connection_type = "${lookup(var.methods[count.index], "connection_type")}"
  connection_id   = "${lookup(var.methods[count.index], "connection_id")}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  depends_on = ["aws_api_gateway_method_response.method_response", "aws_api_gateway_method.method", "aws_api_gateway_integration.api_method_integration"]

  rest_api_id = "${var.api}"
  resource_id = "${aws_api_gateway_resource.resource.id}"

  count       = "${var.num_methods}"
  http_method = "${lookup(var.methods[count.index], "method")}"

  status_code = "200"
}

resource "aws_api_gateway_method_response" "method_response" {
  depends_on = ["aws_api_gateway_method.method", "aws_api_gateway_integration.api_method_integration"]

  rest_api_id = "${var.api}"
  resource_id = "${aws_api_gateway_resource.resource.id}"

  count       = "${var.num_methods}"
  http_method = "${lookup(var.methods[count.index], "method")}"

  status_code = "200"

  response_parameters {
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Credentials" = true
    "method.response.header.Content-Type"                     = true
  }
}

data "template_file" "method" {
  count    = "${var.num_methods}"
  template = "$${method}"

  vars {
    method = "${lookup(var.methods[count.index], "method")}"
  }
}

module "resource_cors" {
  source = "../apigw-cors"

  api      = "${var.api}"
  resource = "${aws_api_gateway_resource.resource.id}"
  methods  = "${data.template_file.method.*.rendered}"
  origin   = "${var.origin}"
}
