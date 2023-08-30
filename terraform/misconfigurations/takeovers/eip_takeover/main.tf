provider "aws" {
  region = var.region
}

# Create EIP
resource "aws_eip" "eip" {
  domain = "vpc"

  tags = var.tags
}

resource "aws_route53_record" "eip_takeover" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = "300"
  records = [aws_eip.eip.public_ip]
}

resource "null_resource" "eip_deletion" {
  depends_on = [aws_eip.eip, aws_route53_record.eip_takeover]

  provisioner "local-exec" {
    command = "aws ec2 release-address --allocation-id ${aws_eip.eip.allocation_id}"
  }
}
