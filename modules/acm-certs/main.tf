data "aws_route53_zone" "default" {
  zone_id = "${var.hosted_zone_id}"
}

resource "aws_acm_certificate" "default" {
  domain_name = "${var.name}.${data.aws_route53_zone.default.name}"

  validation_method = "DNS"

  tags = "${var.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.default.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.default.domain_validation_options.0.resource_record_type}"
  zone_id = "${var.hosted_zone_id}"
  records = ["${aws_acm_certificate.default.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = "${aws_acm_certificate.default.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
