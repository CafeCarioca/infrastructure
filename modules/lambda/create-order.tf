resource "aws_lambda_function" "create-order" {
  function_name = "create-order"
  role          = var.lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  s3_bucket     = var.lambda_bucket
  s3_key        = "lambda-function1.zip"
}
