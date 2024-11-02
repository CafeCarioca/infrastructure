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

# Fin de los añadidos para la función Lambda