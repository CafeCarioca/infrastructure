resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "carioca-lambda-code-bucket"  # Nombre del bucket S3
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "lambda_bucket_versioning" {
  bucket = aws_s3_bucket.lambda_bucket.id  # Referencia correcta al bucket S3
  versioning_configuration {
    status = "Enabled"
  }
}


# Falta agregarle una policy para que la lambda pueda leer
