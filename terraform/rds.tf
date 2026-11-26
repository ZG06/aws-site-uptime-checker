# Subnet group with two subnets in different AZs
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "${var.project_name}-rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }

}

# RDS with PostgreSQL
resource "aws_db_instance" "postgres_db" {
  storage_type                = "gp3"
  allocated_storage           = 20
  identifier                  = "${var.project_name}-db"
  db_subnet_group_name        = aws_db_subnet_group.rds_subnet_group.name
  engine                      = "postgres"
  engine_version              = "18"
  instance_class              = "db.t3.micro"
  db_name                     = "uptime_monitor"
  username                    = "postgres"
  manage_master_user_password = true # Allow RDS to manage username and password
  vpc_security_group_ids      = [aws_security_group.sg_rds.id]
  publicly_accessible         = false
  multi_az                    = false
  skip_final_snapshot         = true # Don't create a final snapshot before destroying the database
}