resource "aws_lambda_function" "create_order" {
  function_name = "create-order"
  role          = aws_iam_role.lambda_exec.arn  # Referencia al rol IAM creado
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  s3_bucket     = "carioca-lambda-code-bucket"  # Cambia esto al nombre de tu bucket
  s3_key        = "create-order.zip"
}

output "create_order_function_name" {
  value = aws_lambda_function.create_order.function_name
}