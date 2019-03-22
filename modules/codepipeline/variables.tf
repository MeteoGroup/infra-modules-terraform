variable "name_prefix" {
  type        = "string"
  default     = ""
  description = "Combined name product/environment"
}

variable "stage" {
  default     = "default"
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "cache_enabled" {
  default     = "true"
  description = "Enable creation of cache bucket"
}

variable "infra_build" {
  type        = "string"
  default     = "false"
  description = "A boolean to enable/disable infrastructure policy creation permissons"
}

variable "app" {
  type        = "string"
  default     = ""
  description = "Elastic Beanstalk application name. If not provided or set to empty string, the ``Deploy`` stage of the pipeline will not be created"
}

variable "env" {
  type        = "string"
  default     = ""
  description = "Elastic Beanstalk environment name. If not provided or set to empty string, the ``Deploy`` stage of the pipeline will not be created"
}

variable "github_oauth_token" {
  description = "GitHub Oauth Token with permissions to access private repositories"
}

variable "repo_owner" {
  description = "GitHub Organization or Person name"
}

variable "repo_name" {
  description = "GitHub repository name of the application to be built (and deployed to Elastic Beanstalk if configured)"
}

variable "branch" {
  description = "Branch of the GitHub repository, _e.g._ ``master``"
}

variable "build_image" {
  default     = "aws/codebuild/docker:1.12.1"
  description = "Docker image for build environment, _e.g._ `aws/codebuild/docker:1.12.1` or `aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0`"
}

variable "build_compute_type" {
  default     = "BUILD_GENERAL1_SMALL"
  description = "`CodeBuild` instance size.  Possible values are: ```BUILD_GENERAL1_SMALL``` ```BUILD_GENERAL1_MEDIUM``` ```BUILD_GENERAL1_LARGE```"
}

variable "buildspec" {
  default     = ""
  description = " Declaration to use for building the project. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html)"
}

# https://www.terraform.io/docs/configuration/variables.html
# It is recommended you avoid using boolean values and use explicit strings
variable "poll_source_changes" {
  type        = "string"
  default     = "true"
  description = "Periodically check the location of your source content and run the pipeline if changes are detected"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('Project', 'ABC')`"
}

variable "aws_region" {
  type        = "string"
  default     = ""
  description = "AWS Region, e.g. us-east-1. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html)"
}

variable "aws_account_id" {
  type        = "string"
  default     = ""
  description = "AWS Account ID. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html)"
}

variable "image_repo_name" {
  type        = "string"
  default     = "UNSET"
  description = "ECR repository name to store the Docker image built by this module. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html)"
}

variable "image_tag" {
  type        = "string"
  default     = "latest"
  description = "Docker image tag in the ECR repository, e.g. 'latest'. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html)"
}

variable "environment_variables" {
  type = "list"

  default = [{
    "name"  = "NO_ADDITIONAL_BUILD_VARS"
    "value" = "TRUE"
  }]

  description = "A list of maps, that contain both the key 'name' and the key 'value' to be used as additional environment variables for the build."
}

variable "cache_expiration_days" {
  type        = "string"
  default     = "7"
  description = "How many days should the build cache be kept"
}

variable "cache_bucket_suffix_enabled" {
  type        = "string"
  default     = "true"
  description = "The cache bucket generates a random 13 character string to generate a unique bucket name. If set to false it uses terraform-null-label's id value"
}

variable "badge_enabled" {
  type        = "string"
  default     = "false"
  description = "Generates a publicly-accessible URL for the projects build badge. Available as badge_url attribute when enabled."
}

variable "build_image" {
  type        = "string"
  default     = "aws/codebuild/docker:1.12.1"
  description = "Docker image for build environment, e.g. 'aws/codebuild/docker:1.12.1' or 'aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0'. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref.html"
}

variable "build_compute_type" {
  type        = "string"
  default     = "BUILD_GENERAL1_SMALL"
  description = "Instance type of the build instance"
}

variable "build_timeout" {
  type        = "string"
  default     = "60"
  description = "How long in minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed."
}

variable "buildspec" {
  type        = "string"
  default     = ""
  description = "Optional buildspec declaration to use for building the project"
}

variable "privileged_mode" {
  type        = "string"
  default     = "false"
  description = "(Optional) If set to true, enables running the Docker daemon inside a Docker container on the CodeBuild instance. Used when building Docker images"
}

variable "source_type" {
  type        = "string"
  default     = "CODEPIPELINE"
  description = "The type of repository that contains the source code to be built. Valid values for this parameter are: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET or S3."
}

variable "source_location" {
  type        = "string"
  default     = ""
  description = "The location of the source code from git or s3."
}

variable "artifact_type" {
  type        = "string"
  default     = "CODEPIPELINE"
  description = "The build output artifact's type. Valid values for this parameter are: CODEPIPELINE, NO_ARTIFACTS or S3."
}

variable "report_build_status" {
  type        = "string"
  default     = "false"
  description = "Set to true to report the status of a build's start and finish to your source provider. This option is only valid when the source_type is BITBUCKET or GITHUB."
}
