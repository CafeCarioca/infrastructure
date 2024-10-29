module "lambda" {
  source = "./modules/lambda"

  # Pasa el ARN del rol como variable
  lambda_exec_role_arn = aws_iam_role.lambda_exec.arn
}

# En el módulo Lambda (variables.tf)
variable "lambda_exec_role_arn" {
  description = "ARN del rol de ejecución para Lambda"
  type        = string
}

# Usarlo en el módulo Lambda (en cancel-order.tf o donde corresponda)
resource "aws_lambda_function" "cancel_order" {
  role = var.lambda_exec_role_arn
}