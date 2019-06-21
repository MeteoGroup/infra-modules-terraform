variable "name_prefix" {
  description = ""
  type        = "string"
  default     = ""
}

variable "prod_prefix" {
  description = "Prefix for last codebuild name in Pipeline"
  type        = "string"
  default     = ""
}

variable "repo_owner" {
  description = ""
  type        = "string"
  default     = "MeteoGroup"
}

variable "repo_name" {
  description = ""
  type        = "string"
  default     = ""
}

variable "branch" {
  description = ""
  type        = "string"
  default     = ""
}

variable "poll_source_changes" {
  description = ""
  type        = "string"
  default     = "false"
}

variable "artifact_s3_bucket" {
  description = ""
  type        = "string"
  default     = ""
}

variable "tags" {
  description = ""
  type        = ""
  default     = {}
}
