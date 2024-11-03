# provider "aws" {
#   region = "us-west-2"
# }

# resource "aws_vpc" "my_vpc" {
#   cidr_block = "10.0.0.0/16"
  
#   tags = {
#     Name = "MyVPC"
#   }
# }

# resource "aws_subnet" "subnet_a" {
#   vpc_id     = aws_vpc.my_vpc.id
#   cidr_block = "10.0.1.0/24"
  
#   tags = {
#     Name = "MySubnetA"
#   }
# }

# resource "aws_subnet" "subnet_b" {
#   vpc_id     = aws_vpc.my_vpc.id
#   cidr_block = "10.0.2.0/24"
  
#   tags = {
#     Name = "MySubnetB"
#   }
# }

# resource "aws_security_group" "rds_sg" {
#   vpc_id = aws_vpc.my_vpc.id

#   ingress {
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "RDS_SG"
#   }
# }