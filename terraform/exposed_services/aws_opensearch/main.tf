provider "aws" {
  region = var.region
}

# Data account id
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "opensearch" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.resource_name}/*"]
  }
}

resource "aws_opensearch_domain" "domain" {
  domain_name    = var.resource_name
  engine_version = var.opensearch_version

  cluster_config {
    instance_type = var.instance_type
  }

  access_policies = data.aws_iam_policy_document.opensearch.json

  advanced_security_options {
    enabled                        = false
    internal_user_database_enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 20
  }

  tags = var.tags

  vpc_options {
    subnet_ids = [ element(local.public_subnets, 0) ]
    security_group_ids = [aws_security_group.opensearch.id]
  }
}

# AWS Security Group allowing access to the OpenSearch domain
resource "aws_security_group" "opensearch" {
  name        = "${var.resource_name}-opensearch"
  description = "Security group for OpenSearch domain ${var.resource_name}"

  vpc_id = var.vpc_id
}

# Allow access to the OpenSearch domain from the public subnets
resource "aws_security_group_rule" "opensearch_ingress" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ip]
  security_group_id = aws_security_group.opensearch.id
}

# Allow access to the OpenSearch domain from the private subnets
resource "aws_security_group_rule" "opensearch_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [data.aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.opensearch.id
}

# Get CIDR from VPC ID
data "aws_vpc" "vpc" {
  id = var.vpc_id
}
