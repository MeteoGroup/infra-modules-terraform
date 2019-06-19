variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
  type        = "string"
  default     = "default"
}

variable "name_prefix" {
  description = "Solution name, e.g. 'app' or 'jenkins'"
  type        = "string"
  default     = "codebuild"
}

variable "environment_variables" {
  description = "A list of maps, that contain both the key 'name' and the key 'value' to be used as additional environment variables for the build."
  type        = "list"

  default = [{
    "name"  = "NO_ADDITIONAL_BUILD_VARS"
    "value" = "TRUE"
  }]
}

variable "enabled" {
  description = "A boolean to enable/disable resource creation"
  type        = "string"
  default     = "true"
}

variable "build_only" {
  type        = "string"
  default     = "false"
  description = "A boolean to enable/disable build only creation"
}

variable "cache_enabled" {
  description = "If cache_enabled is true, create an S3 bucket for storing codebuild cache inside"
  type        = "string"
  default     = "false"
}

variable "cache_expiration_days" {
  type        = "string"
  default     = "7"
  description = "How many days should the build cache be kept"
}

variable "cache_bucket_suffix_enabled" {
  description = "The cache bucket generates a random 13 character string to generate a unique bucket name. If set to false it uses terraform-null-label's id value"
  type        = "string"
  default     = "true"
}

variable "badge_enabled" {
  description = "Generates a publicly-accessible URL for the projects build badge. Available as badge_url attribute when enabled."
  type        = "string"
  default     = "false"
}

variable "build_image" {
  description = "Docker image for build environment, e.g. 'aws/codebuild/docker:1.12.1' or 'aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0'. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref.html"
  type        = "string"
  default     = "aws/codebuild/docker:1.12.1"
}

variable "build_compute_type" {
  description = "Instance type of the build instance"
  type        = "string"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_timeout" {
  description = "How long in minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed."
  type        = "string"
  default     = "60"
}

variable "buildspec" {
  description = "Optional buildspec declaration to use for building the project"
  type        = "string"
  default     = ""
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit', 'XYZ')`"
  type        = "map"
  default     = {}
}

variable "privileged_mode" {
  description = "(Optional) If set to true, enables running the Docker daemon inside a Docker container on the CodeBuild instance. Used when building Docker images"
  type        = "string"
  default     = "false"
}

variable "github_token" {
  description = "(Optional) GitHub auth token environment variable (`GITHUB_TOKEN`)"
  type        = "string"
  default     = ""
}

variable "aws_region" {
  description = "(Optional) AWS Region, e.g. us-east-1. Used as CodeBuild ENV variable when building Docker images. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html"
  type        = "string"
  default     = ""
}

variable "aws_account_id" {
  description = "(Optional) AWS Account ID. Used as CodeBuild ENV variable when building Docker images. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html"
  type        = "string"
  default     = ""
}

variable "image_repo_name" {
  description = "(Optional) ECR repository name to store the Docker image built by this module. Used as CodeBuild ENV variable when building Docker images. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html"
  type        = "string"
  default     = "UNSET"
}

variable "image_tag" {
  description = "(Optional) Docker image tag in the ECR repository, e.g. 'latest'. Used as CodeBuild ENV variable when building Docker images. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html"
  type        = "string"
  default     = "latest"
}

variable "source_type" {
  description = "The type of repository that contains the source code to be built. Valid values for this parameter are: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET or S3."
  type        = "string"
  default     = "CODEPIPELINE"
}

variable "source_location" {
  description = "The location of the source code from git or s3."
  type        = "string"
  default     = ""
}

variable "artifact_type" {
  description = "The build output artifact's type. Valid values for this parameter are: CODEPIPELINE, NO_ARTIFACTS or S3."
  type        = "string"
  default     = "CODEPIPELINE"
}

variable "report_build_status" {
  description = "Set to true to report the status of a build's start and finish to your source provider. This option is only valid when the source_type is BITBUCKET or GITHUB."
  type        = "string"
  default     = "false"
}

variable "vpc_id" {
  description = "VPC ID for the builds to run inside"
  type        = "string"
  default     = ""
}

variable "subnets" {
  description = "A list of subnets for the build to run inside VPC"
  type        = "list"
  default     = []
}

variable "security_groups" {
  description = "A list of security groups for the build to run inside VPC"
  type        = "list"
  default     = []
}
