#module "lambda" {
#  source = "./modules/lambda"

  # Pasa el ARN del rol como variable
#  lambda_exec_role_arn = aws_iam_role.lambda_exec.arn
#}

# En el módulo Lambda (variables.tf)
#variable "lambda_exec_role_arn" {
#  description = "ARN del rol de ejecución para Lambda"
#  type        = string
#}

# Usarlo en el módulo Lambda (en cancel-order.tf o donde corresponda)
#resource "aws_lambda_function" "cancel_order" {
#  role = var.lambda_exec_role_arn
#}


provider "aws" {
  region = "us-east-1" # Cambia la región según tus necesidades
}

resource "aws_s3_bucket" "elcarioca_front" {
  bucket = "elcarioca-front"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name        = "elcarioca-front"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_policy" "elcarioca_front_policy" {
  bucket = aws_s3_bucket.elcarioca_front.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.elcarioca_front.arn}/*"
      }
    ]
  })
}

output "bucket_website_url" {
  description = "URL del sitio web alojado en el bucket S3"
  value       = aws_s3_bucket.elcarioca_front.website_endpoint
}
