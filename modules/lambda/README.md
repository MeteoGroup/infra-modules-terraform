# lambda [![Latest Release](https://img.shields.io/github/release/MeteoGroup/infra-modules-terraform.svg)](https://github.com/MeteoGroup/infra-modules-terraform/releases/latest)

Terraform module designed to generate  AWS Lambda. 

It's Open Source and licensed under the [APACHE2](LICENSE).

## Usage

### Example

```hcl

module "lambda" {
  source                 = "git::https://github.com/MeteoGroup/infra-modules-terraform.git//modules/lambda?ref=master"
  runtime                = "nodejs8.10"
  handler                = "${local.prefix}.handler"
  source_bucket          = "${local.artifacts_bucket}"
  source_prefix          = "${local.prefix}"
  source_version         = "${local.version}"
  access_policy_document = "${data.aws_iam_policy_document.lambda_access.json}"
  function_name          = "name-${local.prefix}"
  source_types           = ["events"]
  source_arns            = ["${aws_cloudwatch_event_rule.build_result.arn}"]
}

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | Host name that will be added to the DNS zone to form FQDN, e.g. 'alb' or 'www' | string | `` | yes |
| hosted_zone_id | DNS zone ID where record will be created and certificate validated | string | `` | yes |
| tags | Additional tags (e.g. `map('Project','ABC')` | map | `<map>` | no |


## Outputs

| Name | Description |
|------|-------------|
| cert_arn | ARN of ACM certificate |




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

