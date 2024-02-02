provider "aws" {
  region = var.region
}

data "aws_ami" "al2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

# Classic Load Balancer resources
resource "aws_elb" "opensearch" {
  name            = var.resource_name
  security_groups = [aws_security_group.opensearch_clb.id]
  subnets         = local.public_subnets
  internal        = false

  listener {
    instance_port     = 9200
    instance_protocol = "tcp"
    lb_port           = 9200
    lb_protocol       = "tcp"
  }

  tags = var.tags
}

# Create a health check
resource "aws_elb_attachment" "opensearch" {
  elb      = aws_elb.opensearch.id
  instance = aws_instance.opensearch.id
}

# Security Group for Classic Load Balancer
resource "aws_security_group" "opensearch_clb" {
  name        = "${var.resource_name}_clb"
  description = var.sensitive_content
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "opensearch_clb_ingress" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ip]
  security_group_id = aws_security_group.opensearch_clb.id
}

resource "aws_security_group_rule" "opensearch_clb_egress" {
  type      = "egress"
  from_port = 9200
  to_port   = 9200
  protocol  = "tcp"

  source_security_group_id = aws_security_group.opensearch.id
  security_group_id        = aws_security_group.opensearch_clb.id
}

resource "aws_instance" "opensearch" {
  ami           = data.aws_ami.al2.id
  instance_type = var.instance_type
  subnet_id     = element(local.private_subnets, 0)
  key_name      = var.key_pair

  vpc_security_group_ids = [aws_security_group.opensearch.id]
  
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name # ssm session manager debugging

  tags = var.tags

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo systemctl enable docker
              sudo usermod -a -G docker ec2-user
              sudo docker pull opensearchproject/opensearch:latest
              sudo docker run -d -p 9200:9200 -p 9600:9600 --restart=always -e "discovery.type=single-node" opensearchproject/opensearch:latest
              EOF
}

# Session manager for some debugging
resource "aws_iam_role" "ssm_role" {
  name        = var.resource_name
  description = var.sensitive_content

  tags = var.tags

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = var.resource_name

  role = aws_iam_role.ssm_role.name
}

# Security group for opensearch
resource "aws_security_group" "opensearch" {
  name        = var.resource_name
  description = var.sensitive_content

  vpc_id = var.vpc_id

  tags = var.tags
}

# Allow inbound traffic
resource "aws_security_group_rule" "opensearch" {
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.opensearch_clb.id
  security_group_id        = aws_security_group.opensearch.id
}

# Allow outbound traffic
resource "aws_security_group_rule" "opensearch_outbound_443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.opensearch.id
}

resource "aws_security_group_rule" "opensearch_outbound_80" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.opensearch.id
}
