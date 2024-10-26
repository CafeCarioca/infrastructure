variable "aws_region" {
  description = "La región de AWS donde se desplegarán los recursos."
  default     = "us-east-1"
}

variable "lambda_role" {
  description = "El ARN del rol IAM para las funciones Lambda."
  type        = string
}

variable "s3_bucket_lambda" {
  description = "El nombre del bucket S3 para el código Lambda."
  type        = string
  default     = "carioca-lambda-code-bucket"
}

variable "s3_bucket_front" {
  description = "El nombre del bucket S3 para el frontend."
  type        = string
  default     = "carioca-front-bucket"
}