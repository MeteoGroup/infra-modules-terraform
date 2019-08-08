output "authorizer_id" {
  description = "Id of created authorizer"
  value       = "${aws_api_gateway_authorizer.authorizer.id}"
}

output "api_id_from_module" {
  value       = "${var.api_id}"
  description = "Id of created resource"
}
