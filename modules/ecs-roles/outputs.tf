output "ec2_ecs_id" {
  value = "${aws_iam_role.ec2_ecs_role.id}"
}

output "ec2_ecs_arn" {
  value = "${aws_iam_role.ec2_ecs_role.arn}"
}

output "ecs_execution_id" {
  value = "${aws_iam_role.ecs_execution_role.id}"
}

output "ecs_execution_arn" {
  value = "${aws_iam_role.ecs_execution_role.arn}"
}
