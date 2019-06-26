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
    location = "${var.artifact_s3_bucket}"
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
  }

  stage {
    name = "Lambda-source-code-test"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts = ["source_output"]

      configuration {
        ProjectName = "${var.projectname_test}"
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
      input_artifacts  = ["source_output"]
      output_artifacts = ["package"]

      configuration {
        ProjectName = "${var.repo_name}-image"
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
