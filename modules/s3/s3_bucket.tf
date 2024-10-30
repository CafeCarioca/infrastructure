# # Bucket para codigo de las Lambdas

# resource "aws_s3_bucket" "lambda_bucket" {
#   bucket        = "carioca-lambda-code-bucket"
#   force_destroy = true
# }

# resource "aws_s3_bucket_versioning" "lambda_bucket_versioning" {
#   bucket = aws_s3_bucket.lambda_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_policy" "lambda_bucket_policy" {
#   bucket = aws_s3_bucket.lambda_bucket.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Id      = "Policy1729635311597"
#     Statement = [
#       {
#         Sid      = "Stmt1729635307903"
#         Effect   = "Allow"
#         Principal = {
#           AWS = "arn:aws:iam::892205733758:role/LabRole"
#         }
#         Action   = "s3:GetObject"
#         Resource = "arn:aws:s3:::carioca-lambda-code-bucket/*"
#       }
#     ]
#   })
# }


# # Bucket del frontend
# resource "aws_s3_bucket" "carioca_front" {
#   bucket        = "carioca-front-bucket"
#   force_destroy = true

#   website {
#     index_document = "index.html"  # Documento de inicio de tu sitio
#     error_document = "error.html"  # Documento de error para manejar errores
#   }
# }


# resource "aws_s3_bucket_versioning" "carioca_front_versioning" {
#   bucket = aws_s3_bucket.carioca_front.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }


# # Desactivar "Block All Public Access" en el bucket
# resource "aws_s3_bucket_public_access_block" "carioca_front_public_access_block" {
#   bucket = aws_s3_bucket.carioca_front.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }


# resource "aws_s3_bucket_policy" "carioca_front_policy" {
#   bucket = aws_s3_bucket.carioca_front.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Id      = "Policy1729635311597"
#     Statement = [
#       {
#         Sid      = "AddPerm"
#         Effect   = "Allow"
#         Principal = {
#           "AWS": "*"
#         }
#         Action   = "s3:GetObject"
#         Resource = "arn:aws:s3:::carioca-front-bucket/*"
#       }
#     ]
#   })
# }
