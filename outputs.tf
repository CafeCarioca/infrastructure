output "lambda_bucket_name" {
  value = aws_s3_bucket.lambda_bucket.bucket
}

output "frontend_bucket_name" {
  value = aws_s3_bucket.carioca_front.bucket
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.cognito_user_pool.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.carioca_order_updates.arn
}