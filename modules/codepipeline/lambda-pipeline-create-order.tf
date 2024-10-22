resource "aws_codepipeline" "lambda-pipeline-create-order" {
  name = "lambda-pipeline-create-order"
  
  artifact_store {
    location = var.pipeline_bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "Lambda"
      version          = "1"
      input_artifacts  = ["source_output"]

      configuration = {
        FunctionName = aws_lambda_function.lambda_function1.function_name
        S3Bucket     = var.lambda_bucket
        S3Key        = "lambda-function1.zip"
      }
    }
  }
}
