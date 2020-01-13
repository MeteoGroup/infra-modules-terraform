data "aws_iam_role" "role_codepipeline" {
  name = "codepipeline-role"
}

data "aws_ssm_parameter" "token" {
  name = "/maersk-repo-primary/oauth-token"
}

resource "aws_codepipeline" "source_build_deploy" {
  name = "${var.name_prefix}"

  role_arn = "${data.aws_iam_role.role_codepipeline.arn}"

  artifact_store {
    location = "${var.codepipeline_bucket}"
    type     = "S3"
  }

  stage {
    name = "Get-Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration {
        OAuthToken           = "${data.aws_ssm_parameter.token.value}"
        Owner                = "${var.repo_owner}"
        Repo                 = "${var.repo_name}"
        Branch               = "${var.branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
      }
    }

    action {
      name             = "Source-of-build-artifacts"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output_props"]

      configuration {
        OAuthToken           = "${data.aws_ssm_parameter.token.value}"
        Owner                = "${var.repo_owner}"
        Repo                 = "maersk-build-artifacts"
        Branch               = "${var.branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
      }
    }
  }

  stage {
    name = "Lambda-source-code-test"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts = ["source_output", "source_output_props"]

      configuration {
        ProjectName   = "${var.projectname_test}"
        PrimarySource = "source_output"
      }
    }
  }

  stage {
    name = "Build-Lambda"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output", "source_output_props"]
      output_artifacts = ["package"]

      configuration {
        ProjectName   = "${var.repo_name}-image"
        PrimarySource = "source_output"
      }
    }
  }

  stage {
    name = "Update-Lambda"

    action {
      name            = "UpdateLambdaAuth"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["package"]

      configuration {
        ProjectName = "${var.repo_name}-lambda${var.prod_prefix}"
      }
    }
  }
}
