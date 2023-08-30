provider "aws" {
  region = var.region
}

resource "aws_ebs_volume" "volume" {
  availability_zone = "${var.region}a"
  size              = 1
  type              = "gp2"

  tags = var.tags
}

resource "aws_ebs_snapshot" "xacct_snapshot" {
  volume_id = aws_ebs_volume.volume.id

  tags = var.tags
}

resource "aws_snapshot_create_volume_permission" "xacct_snapshot" {
  snapshot_id = aws_ebs_snapshot.xacct_snapshot.id
  account_id  = var.account_id
}
