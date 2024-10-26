output "create_order_lambda_function_name" {
  value = module.lambda.create_order_function_name
}

output "cancel_order_lambda_function_name" {
  value = aws_lambda_function.cancel_order.function_name
}

output "s3_bucket_lambda_name" {
  value = aws_s3_bucket.lambda_bucket.bucket
}

output "s3_bucket_front_name" {
  value = aws_s3_bucket.carioca_front.bucket
}