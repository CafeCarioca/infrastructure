resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = var.cognito_user_pool_name

  lambda_config {
    post_confirmation = aws_lambda_function.post_confirmation_function.arn
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
    email_message        = "Your verification link: {##Verify Email##}"
    email_subject        = "Verify your email"
  }

  schema {
    name     = "email"
    required = true
    mutable  = true
    attribute_data_type = "String"
  }
}

resource "aws_cognito_user_pool_client" "cognito_user_pool_client" {
  name         = "carioca_user_pool_client"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["phone", "email", "openid", "profile"]
  callback_urls = ["https://yourfrontend.com/callback"]
  logout_urls    = ["https://yourfrontend.com/logout"]
  generate_secret = false
}
