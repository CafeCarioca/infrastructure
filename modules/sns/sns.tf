# resource "aws_sns_topic" "carioca_order_updates" {
#   name = var.sns_topic_name
# }

# resource "aws_sns_topic_subscription" "email_notification" {
#   topic_arn = aws_sns_topic.carioca_order_updates.arn
#   protocol  = "email"
#   endpoint  = "user@example.com"  # Cambia esto por la dirección de correo electrónico deseada
# }
