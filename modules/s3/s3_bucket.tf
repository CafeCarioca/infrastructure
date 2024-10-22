resource "aws_s3_bucket" "lambda_bucket_name" {
  bucket        = "carioca-lambda-code-bucket"
  force_destroy = true
}

# Configurar versioning utilizando aws_s3_bucket_versioning
resource "aws_s3_bucket_versioning" "lambda_bucket_versioning" {
  bucket = aws_s3_bucket.lambda_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
