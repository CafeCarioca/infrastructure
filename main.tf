# Proveedor de AWS
provider "aws" {
  region = "us-east-1"
}

# Generador de sufijos únicos
resource "random_id" "carioca_front_suffix" {
  byte_length = 4
}

resource "random_id" "carioca_backoffice_suffix" {
  byte_length = 4
}

resource "random_id" "lambda_bucket" {
  byte_length = 4
}

# Definir el rol IAM para Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "LabRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Política básica para ejecución de Lambda
resource "aws_iam_policy" "lambda_basic_execution" {
  name        = "LambdaBasicExecution"
  description = "Permisos básicos para ejecutar funciones Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::carioca-lambda-code-bucket-${random_id.lambda_bucket.hex}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

# Adjuntar la política básica de ejecución al rol de Lambda
resource "aws_iam_role_policy_attachment" "attach_lambda_basic_execution" {
  policy_arn = aws_iam_policy.lambda_basic_execution.arn
  role       = aws_iam_role.lambda_exec_role.name
}

# Política para permitir el acceso al bucket S3
resource "aws_iam_policy" "s3_access_policy" {
  name        = "LambdaS3AccessPolicy"
  description = "Permite acceso a S3 para funciones Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::carioca-lambda-code-bucket-${random_id.lambda_bucket.hex}/*"
      }
    ]
  })
}

# Adjuntar la política al rol
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}

# VPC--------------------------------------------------------------------------------
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MyVPC"
  }
}

# Subnet--------------------------------------------------------------------------------
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "MySubnetA"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "MySubnetB"
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS_SG"
  }
}

# RDS--------------------------------------------------------------------------------
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

resource "aws_db_instance" "default" {
  allocated_storage       = 10
  storage_type            = "standard"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t3.micro"
  identifier              = "mydb"
  username                = "dbuser"
  password                = "dbpassword"
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.my_db_subnet_group.name
  backup_retention_period = 1
  skip_final_snapshot     = true
  multi_az                = false
  performance_insights_enabled = false
  monitoring_interval     = 0
}

# Buckets de S3
# Bucket del frontend
resource "aws_s3_bucket" "carioca_front" {
  bucket        = "carioca-front-bucket-${random_id.carioca_front_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "carioca_front_website" {
  bucket = aws_s3_bucket.carioca_front.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_versioning" "carioca_front_versioning" {
  bucket = aws_s3_bucket.carioca_front.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "carioca_front_public_access_block" {
  bucket = aws_s3_bucket.carioca_front.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "carioca_front_policy" {
  bucket = aws_s3_bucket.carioca_front.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Policy1729635311597"
    Statement = [
      {
        Sid      = "AddPerm"
        Effect   = "Allow"
        Principal = {
          "AWS": "*"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.carioca_front.bucket}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.carioca_front_public_access_block]
}

# Bucket del backoffice
resource "aws_s3_bucket" "carioca_backoffice" {
  bucket        = "carioca-backoffice-bucket-${random_id.carioca_backoffice_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "carioca_backoffice_website" {
  bucket = aws_s3_bucket.carioca_backoffice.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_versioning" "carioca_backoffice_versioning" {
  bucket = aws_s3_bucket.carioca_backoffice.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "carioca_backoffice_public_access_block" {
  bucket = aws_s3_bucket.carioca_backoffice.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "carioca_backoffice_policy" {
  bucket = aws_s3_bucket.carioca_backoffice.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Policy1729635311599"
    Statement = [
      {
        Sid      = "AddPerm"
        Effect   = "Allow"
        Principal = {
          "AWS": "*"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.carioca_backoffice.bucket}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.carioca_backoffice_public_access_block]
}

# Bucket para código de las Lambdas
resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "carioca-lambda-code-bucket-${random_id.lambda_bucket.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "lambda_bucket_versioning" {
  bucket = aws_s3_bucket.lambda_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "lambda_bucket_policy" {
  bucket = aws_s3_bucket.lambda_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Policy1729635311597"
    Statement = [
      {
        Sid      = "Stmt1729635307903"
        Effect   = "Allow"
        Principal = {
          AWS = aws_iam_role.lambda_exec_role.arn
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.lambda_bucket.bucket}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_vpc_access_policy" {
  name        = "LambdaVpcAccessPolicy"
  description = "Permite a Lambda crear interfaces de red en EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_vpc_access_policy" {
  policy_arn = aws_iam_policy.lambda_vpc_access_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}

# -------------------------------------------------------------------------------
# Añadidos al final: Función Lambda en Node.js
# -------------------------------------------------------------------------------

resource "aws_lambda_function" "create_order" {
  function_name = "create-order"
  handler       = "index.handler"  # Cambia esto según tu archivo de entrada y función
  runtime       = "nodejs20.x"   # Cambia este valor según la versión de Node.js que uses
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = "create-order.zip"
  role          = aws_iam_role.lambda_exec_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
    security_group_ids = [aws_security_group.rds_sg.id]
  }
}

resource "aws_lambda_function" "preference-id" {
  function_name = "preference-id"
  handler       = "index.handler"  # Cambia esto según tu archivo de entrada y función
  runtime       = "nodejs20.x"   # Cambia este valor según la versión de Node.js que uses
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = "preference-id.zip"
  role          = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      MERCADOPAGO_ACCESS_TOKEN = "APP_USR-7203094653028388-101112-789555c02a457c562394a689a561ef61-446648853"
    }
  }
}

resource "aws_lambda_function" "get-orders" {
  function_name = "get-order"
  handler       = "index.handler"  # Cambia esto según tu archivo de entrada y función
  runtime       = "nodejs20.x"   # Cambia este valor según la versión de Node.js que uses
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = "get-orders.zip"
  role          = aws_iam_role.lambda_exec_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
    security_group_ids = [aws_security_group.rds_sg.id]
  }
}
# Fin de los añadidos para la función Lambda

# -------------------------------------------------------------------------------
# Añadidos al final: Recursos de API Gateway
# -------------------------------------------------------------------------------

# API Gateway
resource "aws_api_gateway_rest_api" "carioca_api" {
  name        = "CariocaAPI"
  description = "API Gateway para las funciones Lambda de Carioca"
}

# Recurso para create-order
resource "aws_api_gateway_resource" "create_order_resource" {
  rest_api_id = aws_api_gateway_rest_api.carioca_api.id
  parent_id   = aws_api_gateway_rest_api.carioca_api.root_resource_id
  path_part   = "create-order"
}

# Método POST para create-order
resource "aws_api_gateway_method" "create_order_method" {
  rest_api_id   = aws_api_gateway_rest_api.carioca_api.id
  resource_id   = aws_api_gateway_resource.create_order_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integración Lambda para create-order
resource "aws_api_gateway_integration" "create_order_integration" {
  rest_api_id = aws_api_gateway_rest_api.carioca_api.id
  resource_id = aws_api_gateway_resource.create_order_resource.id
  http_method = aws_api_gateway_method.create_order_method.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = aws_lambda_function.create_order.invoke_arn
}

# Permisos Lambda para create-order
resource "aws_lambda_permission" "apigw_lambda_create_order" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_order.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.carioca_api.execution_arn}/*/*"
}

# Recurso para preference-id
resource "aws_api_gateway_resource" "preference_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.carioca_api.id
  parent_id   = aws_api_gateway_rest_api.carioca_api.root_resource_id
  path_part   = "preference-id"
}

# Método GET para preference-id
resource "aws_api_gateway_method" "preference_id_method" {
  rest_api_id   = aws_api_gateway_rest_api.carioca_api.id
  resource_id   = aws_api_gateway_resource.preference_id_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integración Lambda para preference-id
resource "aws_api_gateway_integration" "preference_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.carioca_api.id
  resource_id = aws_api_gateway_resource.preference_id_resource.id
  http_method = aws_api_gateway_method.preference_id_method.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = aws_lambda_function.preference-id.invoke_arn
}

# Permisos Lambda para preference-id
resource "aws_lambda_permission" "apigw_lambda_preference_id" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.preference-id.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.carioca_api.execution_arn}/*/*"
}

# Recurso para get-orders
resource "aws_api_gateway_resource" "get_orders_resource" {
  rest_api_id = aws_api_gateway_rest_api.carioca_api.id
  parent_id   = aws_api_gateway_rest_api.carioca_api.root_resource_id
  path_part   = "get-orders"
}

# Método GET para get-orders
resource "aws_api_gateway_method" "get_orders_method" {
  rest_api_id   = aws_api_gateway_rest_api.carioca_api.id
  resource_id   = aws_api_gateway_resource.get_orders_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integración Lambda para get-orders
resource "aws_api_gateway_integration" "get_orders_integration" {
  rest_api_id = aws_api_gateway_rest_api.carioca_api.id
  resource_id = aws_api_gateway_resource.get_orders_resource.id
  http_method = aws_api_gateway_method.get_orders_method.http_method
  type        = "AWS_PROXY"
  integration_http_method = "GET"
  uri         = aws_lambda_function.get-orders.invoke_arn
}

# Permisos Lambda para get-orders
resource "aws_lambda_permission" "apigw_lambda_get_orders" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get-orders.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.carioca_api.execution_arn}/*/*"
}

# Implementación de API Gateway
resource "aws_api_gateway_deployment" "carioca_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.create_order_integration,
    aws_api_gateway_integration.preference_id_integration,
    aws_api_gateway_integration.get_orders_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.carioca_api.id
  stage_name  = "prod"
}