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
| runtime | Language to use for Lambda | string | `` | yes |
| handler | Program entrypoint for Lambda | string | `` | yes |
| timeout | Timeout after which Lamdba will terminate | string | `10` | yes |
| source_bucket | Bucket to use for loading Lambda source ZIP | string | `` | no |
| source_prefix | S3 prefix to use for loading Lambda ZIP | string | `` | yes |
| source_version | Version of Lambda ZIP to use | string | `` | no |
| function_name | Name for Lambda function | string | `` | no |
| environment_variables | Variables to provide for Lambda environment | map | `` | no |
| access_policy_document | IAM policy provided to Lambda role | string | `` | no |
| source_types | Source types which are allowed to invoke the Lambda. Must align with entries in source_arns variable | list | `` | yes |
| source_arns | Source ARNs which are allowed to invoke the Lambda. Must align with entries in source_types variable | list | `` | no |



## Outputs

| Name | Description |
|------|-------------|
| arn | ARN of  |
| invoke_arn | |




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

