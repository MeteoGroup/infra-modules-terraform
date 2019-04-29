variable "enabled" {
  description = "If set to false, the module will do nothing. This exists because there can be no `count` meta-parameter for a module"
  default     = "true"
}

variable "name" {}

variable "region" {}

variable "tags" {
  type = "map"
}

variable "versioning" {
  default = "false"
}

variable "sns_topic" {
  description = "Whether to create an SNS topic and publish S3 object creations to it"
  default     = false
}

variable "readonly_accounts" {
  description = "List of other AWS accounts which should get read-only access to the bucket - and subscribe access to its SNS topic"
  type        = "list"
  default     = []
}

variable "lifecycle_rules" {
  type    = "list"
  default = []
}

variable "enable_put_logs" {
  description = "If set to true, the module will allow to write to the bucket, usually for logging purposes."
  default     = "false"
}

variable "log_location_prefix" {
  description = "Prefix for log messages location"
  default     = ""
}
