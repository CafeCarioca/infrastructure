# resource "aws_lambda_function" "create_order" {
#   function_name = "create-order"
#   handler       = "lambda_function.lambda_handler"
#   runtime       = "python3.9"
#   s3_bucket     = "carioca-lambda-code-bucket"
#   s3_key        = "create-order.zip"
#   role          = var.lambda_exec_role_arn  # Usar la variable en lugar de aws_iam_role.lambda_exec.arn
# }
