provider "aws" {
  region = var.region
}

# Create a Route53 hosted zone for the subdomain
resource "aws_route53_zone" "sub_zone" {
  name = "${var.resource_name}.${var.parent_domain}."
}

# Add NS records to the parent domain to delegate to the subdomain
resource "aws_route53_record" "sub_ns" {
  zone_id = var.parent_zone_id
  name    = "${var.resource_name}.${var.parent_domain}"
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.sub_zone.name_servers
}

resource "null_resource" "delete_sub_zone" {
  triggers = {
    sub_zone_id = aws_route53_zone.sub_zone.zone_id
  }

  provisioner "local-exec" {
    command = "aws route53 delete-hosted-zone --id ${aws_route53_zone.sub_zone.zone_id}"
  }

  depends_on = [aws_route53_record.sub_ns]
}
