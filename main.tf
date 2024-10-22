provider "aws" {
  region = "us-east-1"
}

# Incluir módulo para Lambda functions
module "lambda" {
  source        = "./modules/lambda"
  lambda_bucket = module.s3.lambda_bucket_name  # Pasar el bucket del módulo S3
}

# Incluir módulo para S3 buckets
module "s3" {
  source = "./modules/s3"
}

# Incluir módulo para CodePipeline
module "pipeline" {
  source = "./modules/codepipeline"
}
