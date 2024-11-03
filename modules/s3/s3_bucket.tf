# provider "aws" {
#   region = "us-east-1"
# }

# # Generador de sufijos únicos
# resource "random_id" "carioca_front_suffix" {
#   byte_length = 4
# }

# resource "random_id" "carioca_backoffice_suffix" {
#   byte_length = 4
# }

# resource "random_id" "lambda_bucket" {
#   byte_length = 4
# }

# # Bucket del frontend
# resource "aws_s3_bucket" "carioca_front" {
#   bucket        = "carioca-front-bucket-${random_id.carioca_front_suffix.hex}"
#   force_destroy = true
# }

# resource "aws_s3_bucket_website_configuration" "carioca_front_website" {
#   bucket = aws_s3_bucket.carioca_front.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "error.html"
#   }
# }

# resource "aws_s3_bucket_versioning" "carioca_front_versioning" {
#   bucket = aws_s3_bucket.carioca_front.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

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
#         Resource = "arn:aws:s3:::${aws_s3_bucket.carioca_front.bucket}/*"
#       }
#     ]
#   })

#   depends_on = [aws_s3_bucket_public_access_block.carioca_front_public_access_block]
# }

# # Bucket del backoffice
# resource "aws_s3_bucket" "carioca_backoffice" {
#   bucket        = "carioca-backoffice-bucket-${random_id.carioca_backoffice_suffix.hex}"
#   force_destroy = true
# }

# resource "aws_s3_bucket_website_configuration" "carioca_backoffice_website" {
#   bucket = aws_s3_bucket.carioca_backoffice.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "error.html"
#   }
# }

# resource "aws_s3_bucket_versioning" "carioca_backoffice_versioning" {
#   bucket = aws_s3_bucket.carioca_backoffice.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "carioca_backoffice_public_access_block" {
#   bucket = aws_s3_bucket.carioca_backoffice.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

# resource "aws_s3_bucket_policy" "carioca_backoffice_policy" {
#   bucket = aws_s3_bucket.carioca_backoffice.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Id      = "Policy1729635311599"
#     Statement = [
#       {
#         Sid      = "AddPerm"
#         Effect   = "Allow"
#         Principal = {
#           "AWS": "*"
#         }
#         Action   = "s3:GetObject"
#         Resource = "arn:aws:s3:::${aws_s3_bucket.carioca_backoffice.bucket}/*"
#       }
#     ]
#   })

#   depends_on = [aws_s3_bucket_public_access_block.carioca_backoffice_public_access_block]
# }

# # Bucket para codigo de las Lambdas

# resource "aws_s3_bucket" "lambda_bucket" {
#   bucket        = "carioca-lambda-code-bucket-${random_id.lambda_bucket.hex}"
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