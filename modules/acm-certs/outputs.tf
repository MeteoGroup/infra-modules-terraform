#output "cert_arn" {
#  description = "Certificate ARN"
#  value       = "${join("", aws_acm_certificate_validation.default.*.certificate_arn)}"
#}

output "cert_arn" {
  description = "Certificate ARN"
  value       = "${aws_acm_certificate_validation.default.certificate_arn}"
}
