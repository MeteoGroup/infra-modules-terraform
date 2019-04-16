output "authorizer_id" {
  description = "Id of created authorizer"
  value       = "${aws_api_gateway_authorizer.authorizer.id}"
}

output "api_id_from_module" {
  value       = "${var.api_id}"
  description = "Id of created resource"
}

output "function_name" {
  value       = "${var.function_name}"
  description = "Function name of created Lambda"
}

output "invoke_arn" {
  value       = "${aws_lambda_function.authorizer.invoke_arn}"
  description = "Invoke ARN for lambda function"
}
