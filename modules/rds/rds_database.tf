provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
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
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id]
}

resource "aws_db_instance" "default" {
  allocated_storage       = 5  # Mínimo requerido
  storage_type            = "standard"  # Almacenamiento magnético estándar
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t3.micro"  # Clase de instancia económica
  identifier              = "mydb"
  username                = "dbuser"
  password                = "dbpassword"
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.my_db_subnet_group.name
  backup_retention_period = 1  # Retención de copia de seguridad mínima
  skip_final_snapshot     = true  # Para evitar costos adicionales al destruir
  multi_az                = false  # Sin alta disponibilidad
  performance_insights_enabled = false  # Deshabilitar Performance Insights
  monitoring_interval     = 0  # Deshabilitar monitoreo avanzado
}