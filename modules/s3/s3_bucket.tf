resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "carioca-lambda-code-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "lambda_bucket_versioning" {
  bucket = aws_s3_bucket.lambda_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "lambda_bucket_policy" {
  bucket = aws_s3_bucket.lambda_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Policy1729635311597"
    Statement = [
      {
        Sid      = "Stmt1729635307903"
        Effect   = "Allow"
        Principal = {
          AWS = "arn:aws:iam::892205733758:role/LabRole"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::carioca-lambda-code-bucket/*"
      }
    ]
  })
}
