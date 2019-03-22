resource "aws_elastic_beanstalk_application" "default" {
  name        = "${var.name_prefix}"
  description = "${var.description}"
}
