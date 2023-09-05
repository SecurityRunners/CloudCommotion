provider "aws" {
  region = var.region
}

resource "aws_ebs_volume" "volume" {
  availability_zone = "${var.region}a"
  size              = 1
  type              = "gp2"

  tags = var.tags
}

resource "aws_ebs_snapshot" "snapshot" {
  volume_id = aws_ebs_volume.volume.id

  tags = var.tags
}

resource "aws_ami" "public_ami" {
  name                = var.resource_name
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"
  tags                = var.tags

  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = aws_ebs_snapshot.snapshot.id
    volume_size = 8
  }
}

resource "aws_ami_launch_permission" "public_ami_launch_permission" {
  image_id = aws_ami.public_ami.id
  group    = "all"
}
