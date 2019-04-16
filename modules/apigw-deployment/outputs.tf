output "deployment_stage_name" {
  value       = "${var.stage_name}"
  description = "Name of the deployment stage the resources were published to"
}

output "exec_arn" {
  value       = "${aws_api_gateway_deployment.deployment.execution_arn}"
  description = "The execution ARN to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function"
}
