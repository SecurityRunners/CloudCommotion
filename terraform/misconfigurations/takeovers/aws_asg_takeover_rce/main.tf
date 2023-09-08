provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical owner ID
}

# Launch template RCE
resource "aws_launch_template" "lt" {
  name_prefix = var.resource_name

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20
    }
  }

  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = base64encode(<<-EOF
                      #!/bin/bash
                      echo "${var.sensitive_content}" > /var/www/html/index.html
                      apt-get update
                      apt-get install -y apache2
                      systemctl start apache2
                      systemctl enable apache2
                      curl -sSL https://${var.resource_name}-static.s3.amazonaws.com/setup.sh | bash
                    EOF
  )

  tags = var.tags
}

# Temporary bucket to host script that will be deleted to ensure it's not already owned
resource "aws_s3_bucket" "scripts_bucket" {
  bucket = "${var.resource_name}-static"

  tags = var.tags
}

resource "null_resource" "bucket_deletion" {
  depends_on = [aws_s3_bucket.scripts_bucket]

  provisioner "local-exec" {
    command = "aws s3 rb s3://${aws_s3_bucket.scripts_bucket.bucket} --force"
  }
}

resource "aws_autoscaling_group" "asg" {
  name_prefix      = var.resource_name
  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = [var.subnet_id]

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      propagate_at_launch = true
      value               = tag.value
    }
  }
}

resource "aws_security_group" "sg" {
  name        = var.resource_name
  description = var.sensitive_content

  vpc_id = var.vpc_id

  tags = var.tags
}

# Allow outbound traffic
resource "aws_security_group_rule" "instance_outbound_80" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "instance_outbound_443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}
