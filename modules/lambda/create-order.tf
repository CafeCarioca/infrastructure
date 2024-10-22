resource "aws_lambda_function" "create-order" {
  function_name = "create-order"
  role          = "LabRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  s3_bucket     = var.lambda_bucket
  s3_key        = "create-order.zip"
}
