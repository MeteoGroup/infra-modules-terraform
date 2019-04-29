output "id" {
  value = "${element(concat(aws_s3_bucket.default.*.id, list("")), 0)}"
}

output "arn" {
  value = "${element(concat(aws_s3_bucket.default.*.arn, list("")), 0)}"
}
