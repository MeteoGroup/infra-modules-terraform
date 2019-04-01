# Batch [![Latest Release](https://img.shields.io/github/release/MeteoGroup/infra-modules-terraform.svg)](https://github.com/MeteoGroup/infra-modules-terraform/releases/latest)

Terraform module designed to generate for easily and efficiently run hundreds of thousands of batch computing jobs on AWS. 

It's Open Source and licensed under the [APACHE2](LICENSE).

## Usage

### Example

``` hcl

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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name_prefix | Solution name | string | `` | yes |
| tags | Additional tags (e.g. `map('Project', 'ABC')` | map | `` | no |
| job_vcpus | The number of vCPUs reserved for the container. |  | | |
| job_memory | The hard limit (in MiB) of memory to present to the container. |  | | |
| worker_instance_type | Instance types that may be launched | | | |
| subnet | VPC subnets into which the compute resources are launched | | | | 
| security_group | A list of EC2 security group that are associated with instances launched in the compute environment. | | | | 
| job_policy_document | Job definitions policy | | | |
| repository_url | url to image used to start a container. | | | |
| privileged | When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user) | | | |
| command_array | The command that is passed to the container | | | |
| environment_variables | The environment variables to pass to a container | | | |



## Outputs

| Name | Description |
|------|-------------|
| definition_arn |  |
| queue_arn | |
| iam_role_batch_instance_arn | | 


## Copyright

Copyright © 2019 [MeteoGroup](https://cpco.io/copyright)


## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.

## Trademarks

All other trademarks referenced herein are the property of their respective owners.
