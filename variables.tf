variable "lambda_bucket" {
  type        = string
  description = "Nombre del bucket S3 donde se almacena el código de las funciones Lambda"
}

variable "lambda_role_arn" {
  type        = string
  description = "ARN del rol IAM para la función Lambda"
}
