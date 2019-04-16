output "api_id_from_module" {
  value       = "${var.api_id}"
  description = "Id of created resource"
}

output "execution_arn" {
  value       = "${module.api_deployment.exec_arn}"
  description = "Id of created resource"
}
