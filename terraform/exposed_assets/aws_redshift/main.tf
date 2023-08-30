provider "aws" {
  region = var.region
}

resource "aws_redshift_cluster" "cluster" {
  cluster_identifier     = var.resource_name
  database_name          = "db"
  master_username        = "admin"
  master_password        = resource.random_password.password.result
  node_type              = var.node_type
  cluster_type           = "single-node"
  availability_zone      = "${var.region}a"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.redshift.id]

  cluster_subnet_group_name = aws_redshift_subnet_group.sgroup.name

  tags = var.tags
}

resource "aws_redshift_subnet_group" "sgroup" {
  name       = var.resource_name
  subnet_ids = [var.subnet_id]

  tags = var.tags
}
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group" "redshift" {
  name        = var.resource_name
  description = var.sensitive_content

  vpc_id = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "redshift" {
  type              = "ingress"
  from_port         = 5439
  to_port           = 5439
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ip]
  security_group_id = aws_security_group.redshift.id
}

resource "aws_iam_role" "redshift_role" {
  name = "${var.resource_name}-redshift-role"

  assume_role_policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "redshift_s3_read_only" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "redshift_s3_read_only_attachment" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = data.aws_iam_policy.redshift_s3_read_only.arn
}
