# Define la función Lambda para obtener una orden
resource "aws_lambda_function" "get_order" {
  function_name = "get_order_function"
  handler       = "get_order.handler"               # Asegúrate de que este coincida con tu código
  runtime       = "python3.8"                       # Cambia según tu versión de Python

  # S3 bucket y clave donde se almacena el código de la función Lambda
  s3_bucket = "carioca-lambda-code-bucket"          # Cambia esto al nombre de tu bucket
  s3_key    = "path/to/your/get_order.zip"          # Cambia a la ubicación de tu archivo zip

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.carioca_order_updates.arn
    }
  }

  role = var.lambda_exec_role_arn                   # Referencia al ARN del rol de ejecución para Lambda
}

# Crea un recurso en API Gateway para obtener una orden
resource "aws_api_gateway_resource" "get_order" {
  rest_api_id = aws_api_gateway_rest_api.carioca_api.id
  parent_id   = aws_api_gateway_rest_api.carioca_api.root_resource_id
  path_part   = "getOrder"
}

# Define el método GET en API Gateway para el recurso getOrder
resource "aws_api_gateway_method" "get_order_method" {
  rest_api_id   = aws_api_gateway_rest_api.carioca_api.id
  resource_id   = aws_api_gateway_resource.get_order.id
  http_method   = "GET"
  authorization = "NONE"                            # Cambia según sea necesario

  request_parameters = {
    "method.request.querystring.orderId" = true     # Requiere el parámetro de consulta orderId
  }
}

# Configura la integración entre API Gateway y la función Lambda para obtener la orden
resource "aws_api_gateway_integration" "get_order_integration" {
  rest_api_id             = aws_api_gateway_rest_api.carioca_api.id
  resource_id             = aws_api_gateway_resource.get_order.id
  http_method             = aws_api_gateway_method.get_order_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_order.invoke_arn
}
