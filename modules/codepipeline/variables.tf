variable "name_prefix" {
  description = "Combined name product/environment"
  type        = "string"
  default     = ""
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
  type        = "string"
  default     = "default"
}

variable "cache_enabled" {
  description = "Enable creation of cache bucket"
  type        = "string"
  default     = "true"
}

variable "infra_build" {
  description = "A boolean to enable/disable infrastructure policy creation permissons"
  type        = "string"
  default     = "false"
}

variable "app" {
  description = "Elastic Beanstalk application name. If not provided or set to empty string, the ``Deploy`` stage of the pipeline will not be created"
  type        = "string"
  default     = ""
}

variable "env" {
  description = "Elastic Beanstalk environment name. If not provided or set to empty string, the ``Deploy`` stage of the pipeline will not be created"
  type        = "string"
  default     = ""
}

variable "github_oauth_token" {
  description = "GitHub Oauth Token with permissions to access private repositories"
  type        = "string"
  default     = ""
}

variable "repo_owner" {
  description = "GitHub Organization or Person name"
  type        = "string"
  default     = ""
}

variable "repo_name" {
  description = "GitHub repository name of the application to be built (and deployed to Elastic Beanstalk if configured)"
  type        = "string"
  default     = ""
}

variable "branch" {
  description = "Branch of the GitHub repository, _e.g._ ``master``"
  type        = "string"
  default     = ""
}

# https://www.terraform.io/docs/configuration/variables.html
# It is recommended you avoid using boolean values and use explicit strings
variable "poll_source_changes" {
  description = "Periodically check the location of your source content and run the pipeline if changes are detected"
  type        = "string"
  default     = "true"
}

variable "tags" {
  description = "Additional tags (e.g. `map('Project', 'ABC')`"
  type        = "map"
  default     = {}
}

variable "aws_region" {
  description = "AWS Region, e.g. us-east-1. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html)"
  type        = "string"
  default     = ""
}

variable "aws_account_id" {
  description = "AWS Account ID. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html)"
  type        = "string"
  default     = ""
}

variable "image_repo_name" {
  description = "ECR repository name to store the Docker image built by this module. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html)"
  type        = "string"
  default     = "UNSET"
}

variable "image_tag" {
  description = "Docker image tag in the ECR repository, e.g. 'latest'. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html)"
  type        = "string"
  default     = "latest"
}

variable "environment_variables" {
  description = "A list of maps, that contain both the key 'name' and the key 'value' to be used as additional environment variables for the build."
  type        = "list"

  default = [{
    "name"  = "NO_ADDITIONAL_BUILD_VARS"
    "value" = "TRUE"
  }]
}

variable "cache_expiration_days" {
  description = "How many days should the build cache be kept"
  type        = "string"
  default     = "7"
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

variable "privileged_mode" {
  description = "(Optional) If set to true, enables running the Docker daemon inside a Docker container on the CodeBuild instance. Used when building Docker images"
  type        = "string"
  default     = "false"
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
