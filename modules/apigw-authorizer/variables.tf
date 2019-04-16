variable "region" {
  description = "AWS Region"
}

variable "environment" {
  description = "Environment name"
}

variable "api_id" {}
variable "bucket" {}
variable "key" {}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Days to retain logs in CloudWatch"
  default     = 30
}

variable "function_name" {
  description = "Lambda function name"
  default     = "auth"
}

variable "authorizer_name" {
  description = "Authorizer name"
  default     = "authorizer"
}

variable "handler" {
  description = "Handler for Lambda function"
  default     = ""
}

variable "memory_size" {
  description = "Lambda memory"
  default     = 128
}

variable "lambda_role_name" {
  description = "Lambda role name"
  default     = "authorizer"
}

variable "lambda_role_path" {
  description = "Lambda role path"
  default     = "/"
}

variable "lambda_role_policy_arns" {
  description = "Lambda role policy attachment ARNs"
  type        = "list"
  default     = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

variable "tags" {
  type    = "map"
  default = {}
}

variable "timeout" {
  default = 30
}

variable "environment_variables" {
  type = "map"

  default = {
    dummy = ""
  }
}
