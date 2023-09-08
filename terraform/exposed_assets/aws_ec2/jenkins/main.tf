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

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.al2.id
  instance_type = var.instance_type
  subnet_id     = element(local.public_subnets, 0)
  key_name      = var.key_pair

  security_groups      = [aws_security_group.jenkins.id]
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name # ssm session manager debugging

  tags = var.tags

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo systemctl enable docker
              sudo usermod -a -G docker ec2-user
              sudo docker pull jenkins/jenkins:lts
              sudo docker run -d -p 8080:8080 -p 50000:50000 --restart=always -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" jenkins/jenkins:lts-jdk11
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

# Security group for jenkins
resource "aws_security_group" "jenkins" {
  name        = var.resource_name
  description = var.sensitive_content

  vpc_id = var.vpc_id

  tags = var.tags
}

# Allow inbound traffic
resource "aws_security_group_rule" "jenkins" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ip]
  security_group_id = aws_security_group.jenkins.id
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ip]
  security_group_id = aws_security_group.jenkins.id
}

# Allow outbound traffic
resource "aws_security_group_rule" "jenkins_outbound_443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins.id
}

resource "aws_security_group_rule" "jenkins_outbound_80" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins.id
}
