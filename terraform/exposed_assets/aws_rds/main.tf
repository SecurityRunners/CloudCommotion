provider "aws" {
  region = var.region
}

resource "aws_db_instance" "rds_instance" {
  identifier = var.resource_name

  db_name              = "mydb"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.node_type
  username             = "admin"
  password             = resource.random_password.password.result
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  multi_az             = false

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  tags = var.tags
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.resource_name}-subnet-group"
  subnet_ids = local.public_subnets

  tags = var.tags
}

resource "aws_security_group" "rds_security_group" {
  name        = var.resource_name
  description = var.sensitive_content
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "rds_security_group_rule" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ip]
  security_group_id = aws_security_group.rds_security_group.id
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
