variable "api_id" {
  type        = "string"
  description = "ID for API Gateway"
}

variable "stage_name" {
  type        = "string"
  description = "Current place in the API's lifecycle, e.g. production"
}

variable "stage_description" {
  type        = "string"
  description = "Short description of the stage, e.g. API released for public consumption"
}

variable "deployment_description" {
  type        = "string"
  description = "Short description of the first deployment, e.g. initial cut of the API"
}

variable "metrics_enabled" {
  type        = "string"
  description = "Specifies whether Amazon CloudWatch metrics are enabled for this method."
}

variable "logging_level" {
  type        = "string"
  description = "Specifies the logging level for this method, which effects the log entries pushed to Amazon CloudWatch Logs. The available levels are OFF, ERROR, and INFO."
}

variable "data_trace_enabled" {
  type        = "string"
  description = "Specifies whether data trace logging is enabled for this method, which effects the log entries pushed to Amazon CloudWatch Logs."
}

variable "throttling_burst_limit" {
  type        = "string"
  description = "Specifies the throttling burst limit."
}

variable "throttling_rate_limit" {
  type        = "string"
  description = "Specifies the throttling rate limit."
}
