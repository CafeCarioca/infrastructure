# resource "aws_iam_role" "lambda_exec" {
#   name               = "lambda_exec_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#         Effect = "Allow"
#         Sid    = ""
#       },
#     ]
#   })
# }

# resource "aws_iam_policy_attachment" "lambda_policy_attach" {
#   name       = "lambda-policy-attachment"
#   roles      = [aws_iam_role.lambda_exec.name]
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }