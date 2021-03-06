variable "runtime" {
  description = "Language to use for Lambda"
  type        = "string"
  default     = ""
}

variable "handler" {
  description = "Program entrypoint for Lambda"
  type        = "string"
  default     = ""
}

variable "timeout" {
  description = "Timeout after which Lamdba will terminate"
  type        = "string"
  default     = "10"
}

variable "source_dir" {
  description = "Path to directory with Lambda source"
  type        = "string"
}

variable "source_bucket" {
  description = "Bucket to use for loading Lambda source ZIP"
  type        = "string"
}

variable "source_prefix" {
  description = "S3 prefix to use for loading Lambda ZIP"
  type        = "string"
  default     = ""
}

variable "function_name" {
  description = "Name for Lambda function"
  type        = "string"
}

variable "environment_variables" {
  description = "Variables to provide for Lambda environment"
  type        = "map"

  default = {
    dummy = ""
  }
}

variable "access_policy_document" {
  description = "IAM policy provided to Lambda role"
  type        = "string"
}

variable "source_types" {
  description = "Source types which are allowed to invoke the Lambda. Must align with entries in source_arns variable"
  type        = "list"
  default     = [""]
}

variable "source_arns" {
  description = "Source ARNs which are allowed to invoke the Lambda. Must align with entries in source_types variable"
  type        = "list"
}
