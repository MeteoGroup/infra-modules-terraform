# IAM roles module
This module will create iam roles in AWS for Marine project.
These roles are:
* ecs_execution_role (role is assumed to ecs-tasks service)
* ec2_ecs_role (role is assumed to ec2 service)

To use this module you should provide:
* name_prefix

Outputs are arns and ids for roles:
* ec2_ecs_id
* ecs_execution_id
* ec2_ecs_arn
* ecs_execution_arn

Code sample to illustrate how to use it:
```HCL
# Local tags variable
locals {
    name_prefix = "test"
}

# That's how you call module
module "iam_roles" {
  source        = "../modules/iam_roles"
  
  name_prefix   = "${local.name_prefix}"
}

resource "aws_ecs_task_definition" "mapserver" {
  family             = "some-family"
  execution_role_arn = "${module.iam_roles.ecs_execution_arn}"
  task_role_arn      = "${module.iam_roles.ecs_execution_arn}"
  }
}
```