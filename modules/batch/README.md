
```
module "batch" {
  source                = "git::https://github.com/MeteoGroup/infra-modules-terraform.git//modules/batch?ref=master"
  name_prefix           = "name_prefix"
  tags                  = "tags"
  job_vcpus             = "vcpus"
  job_memory            = "memory"
  worker_instance_type  = "instance_type"
  job_policy_document   = "policy"

  environment_variables =
    [
      {
        name  = "SOME_VAR",
        value = "variable_value"
      },
    ]

  subnet         = "subnet"
  security_group = "security_group"

  repository_url = "repo_url"
}
```
