# EC2 security group
resource "aws_security_group" "sg_ec2" {
  name        = "${var.project_name}-sg-ec2"
  description = "EC2 Security Group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-sg-ec2"
  }
}

# Attach egress rules to the EC2 security group
resource "aws_vpc_security_group_egress_rule" "sg_ec2_egress_rules" {
  description       = "Only allow outbound traffic"
  security_group_id = aws_security_group.sg_ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all ports
}

# RDS security group
resource "aws_security_group" "sg_rds" {
  name        = "${var.project_name}-sg-rds"
  description = "RDS Security Group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-sg-rds"
  }
}

# Attach ingress rules to the RDS security group
resource "aws_vpc_security_group_ingress_rule" "sg_rds_ingress_rules" {
  description                  = "Only allow inbound traffic from EC2 on port 5432 (PostgreSQL)"
  security_group_id            = aws_security_group.sg_rds.id
  referenced_security_group_id = aws_security_group.sg_ec2.id # Chaig sg_rds to sg_ec2 to allow connection
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}