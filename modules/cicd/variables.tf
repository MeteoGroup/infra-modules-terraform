variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
  type        = "string"
  default     = "default"
}

variable "name_prefix" {
  description = "Solution name, e.g. 'app' or 'jenkins'"
  type        = "string"
  default     = "app"
}

variable "enabled" {
  description = "Enable ``CodePipeline`` creation"
  type        = "string"
  default     = "true"
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

variable "github_token" {
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

variable "build_image" {
  description = "Docker image for build environment, _e.g._ `aws/codebuild/docker:1.12.1` or `aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0`"
  type        = "string"
  default     = "aws/codebuild/docker:1.12.1"
}

variable "build_compute_type" {
  description = "`CodeBuild` instance size.  Possible values are: ```BUILD_GENERAL1_SMALL``` ```BUILD_GENERAL1_MEDIUM``` ```BUILD_GENERAL1_LARGE```"
  type        = "string"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "buildspec" {
  description = " Declaration to use for building the project. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html)"
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
  description = "Additional tags (e.g. `map('BusinessUnit', 'XYZ')`"
  type        = "map"
  default     = {}
}

variable "privileged_mode" {
  description = "If set to true, enables running the Docker daemon inside a Docker container on the CodeBuild instance. Used when building Docker images"
  type        = "string"
  default     = "false"
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
