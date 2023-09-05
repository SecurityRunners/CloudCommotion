provider "aws" {
  region = var.region
}

resource "aws_ebs_volume" "volume" {
  availability_zone = "${var.region}a"
  size              = 1
  type              = "gp2"

  tags = var.tags
}

resource "aws_ebs_snapshot" "public_snapshot" {
  volume_id = aws_ebs_volume.volume.id

  tags = var.tags
}

# Forgotten issue and not possible through terraform
# https://github.com/hashicorp/terraform-provider-aws/issues/13198
resource "null_resource" "make_snapshot_public" {
  provisioner "local-exec" {
    command = "aws ec2 modify-snapshot-attribute --snapshot-id ${aws_ebs_snapshot.public_snapshot.id} --attribute createVolumePermission --operation-type add --group-names all"
  }

  triggers = {
    snapshot_id = aws_ebs_snapshot.public_snapshot.id
  }

  depends_on = [aws_ebs_snapshot.public_snapshot]
}

