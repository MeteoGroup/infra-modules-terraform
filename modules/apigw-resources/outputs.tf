output "resource" {
  value       = "${aws_api_gateway_resource.resource.id}"
  description = "Id of created resource"
}

output "api_id_from_module" {
  value       = "${var.api}"
  description = "Id of created resource"
}
