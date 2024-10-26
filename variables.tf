variable "aws_region" {
  description = "La región de AWS donde se desplegará la infraestructura"
  default     = "us-east-1"  # Puedes cambiarlo según tus necesidades
}

variable "cognito_user_pool_name" {
  description = "Nombre del User Pool de Cognito"
  default     = "CariocaUserPool"
}

variable "s3_bucket_lambda_code" {
  description = "Nombre del bucket para el código de las Lambdas"
  default     = "carioca-lambda-code-bucket"
}

variable "s3_bucket_frontend" {
  description = "Nombre del bucket para el frontend"
  default     = "carioca-front-bucket"
}

variable "sns_topic_name" {
  description = "Nombre del topic de SNS"
  default     = "CariocaOrderUpdates"
}