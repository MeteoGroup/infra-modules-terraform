locals {
  # How many Docker Image versions AWS ECR will store
  max_image_count = 7
}

resource "aws_ecr_repository" "this" {
  name = "${var.name}"
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = "${aws_ecr_repository.this.name}"

  policy = <<EOF
{
  "rules": [{
    "rulePriority": 1,
    "selection": {
      "tagStatus": "untagged",
      "countType": "imageCountMoreThan",
      "countNumber": ${local.max_image_count}
    },
    "action": {
      "type": "expire"
    }
  }]
}
EOF
}
