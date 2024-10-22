resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "carioca-lambda-code-bucket"
  force_destroy = true  # Para forzar la eliminación del bucket y su contenido en caso de que se destruya
  versioning {
    enabled = true  # Activa la versioning en el bucket para mantener diferentes versiones del código
  }
}

output "lambda_bucket_name" {
  value = aws_s3_bucket.lambda_bucket.bucket
}
