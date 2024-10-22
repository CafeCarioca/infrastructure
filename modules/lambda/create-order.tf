resource "aws_lambda_function" "create-order" {
  function_name = "create-order"
  role          = "arn:aws:iam::892205733758:role/LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  s3_bucket     = "carioca-lambda-code-bucket"
  s3_key        = "create-order.zip"
}

output "create_order_function_name" {
  value = aws_lambda_function.create-order.function_name
}
