resource "aws_lambda_function" "cancel_order" {
  function_name = "cancel_order_function"
  handler       = "cancel_order.handler"  # Asegúrate de que este coincida con tu código
  runtime       = "python3.8"  # Cambia según tu versión de Python

  s3_bucket = "carioca-lambda-code-bucket"  # Cambia esto al nombre de tu bucket
  s3_key    = "path/to/your/cancel_order.zip"  # Cambia a la ubicación de tu archivo zip

  environment {
    SNS_TOPIC_ARN = aws_sns_topic.carioca_order_updates.arn
  }

  role = aws_iam_role.lambda_exec.arn  # Referencia al rol IAM creado
}

resource "aws_api_gateway_resource" "cancel_order" {
  rest_api_id = aws_api_gateway_rest_api.carioca_api.id
  parent_id   = aws_api_gateway_rest_api.carioca_api.root_resource_id
  path_part   = "cancelOrder"
}

resource "aws_api_gateway_method" "cancel_order_method" {
  rest_api_id   = aws_api_gateway_rest_api.carioca_api.id
  resource_id   = aws_api_gateway_resource.cancel_order.id
  http_method   = "POST"
  authorization = "NONE"  # Cambia según sea necesario

  request_parameters = {
    "method.request.querystring.orderId" = true
  }
}

resource "aws_api_gateway_integration" "cancel_order_integration" {
  rest_api_id = aws_api_gateway_rest_api.carioca_api.id
  resource_id = aws_api_gateway_resource.cancel_order.id
  http_method = aws_api_gateway_method.cancel_order_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.cancel_order.invoke_arn
}