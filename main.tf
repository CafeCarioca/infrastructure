provider "aws" {
  region = "us-east-1"
}

# Incluir módulo para Lambda functions
module "lambda" {
  source        = "./modules/lambda"
  }

output "create_order_lambda_function_name" {
  value = module.lambda.create_order_function_name
}

# Incluir módulo para S3 buckets
module "s3" {
  source = "./modules/s3"
}

# Incluir módulo para CodePipeline
module "pipeline" {
  source = "./modules/codepipeline"
}

