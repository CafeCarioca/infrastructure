resource "aws_codepipeline" "lambda_pipeline_create_order" {
  name = "lambda_pipeline_create_order"
  
  # Otros bloques de configuración...

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
        FunctionName = module.lambda.create_order_function_name  # Referenciar el output del módulo Lambda
        S3Bucket     = "carioca-lambda-code-bucket"
        S3Key        = "create-order.zip"
      }
    }
  }
}
