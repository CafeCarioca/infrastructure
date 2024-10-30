resource "aws_db_instance" "cafe_elcarioca_db" {
  allocated_storage       = 20
  storage_type            = "gp3"
  engine                  = "mysql"
  engine_version          = "8.0.39"
  instance_class          = "db.t4g.micro"
  identifier              = "cafe-elcarioca-db"
  username                = "admin"
  password                = "admin1234"  # Recomendación: Usa variables o secretos para la contraseña
  db_subnet_group_name    = "default-vpc-037052e24bde4c9f0"
  vpc_security_group_ids  = ["sg-0123456789abcdef0"]  # Reemplaza con el ID de tu security group
  skip_final_snapshot     = true  # Evita crear un snapshot al eliminar la instancia
  publicly_accessible     = false # Mantiene la base de datos en una red privada
  multi_az                = false # Usa una única zona de disponibilidad (FreeTier)

  # Configura la autenticación solo con contraseña
  apply_immediately       = true  # Aplica cambios inmediatamente
  parameter_group_name    = "default.mysql8.0"

  # Opciones de mantenimiento
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "04:00-06:00"

  # Configura backups automáticos (si deseas)
  backup_retention_period = 7
  delete_automated_backups = true  # Elimina backups automáticos al borrar la instancia

  # Preferencias de disponibilidad
  availability_zone       = null  # No se especifica zona, AWS elige una automáticamente
  ca_cert_identifier      = "rds-ca-rsa2048-g1"  # Certificado de autoridad por defecto
}
