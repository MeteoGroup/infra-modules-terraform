output "definition_arn" {
  value = "${aws_batch_job_definition.this.arn}"
}

output "queue_arn" {
  value = "${aws_batch_job_queue.main_queue.arn}"
}

#output "launch_template_name" {
#  value = "${aws_launch_template.this.name}"
#}
#
#output "launch_template_version" {
#  value = "${aws_launch_template.this.latest_version}"
#}

output "iam_role_batch_instance_arn" {
  value = "${aws_iam_role.batch_instance.arn}"
}
