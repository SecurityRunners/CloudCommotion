provider "aws" {
  region = var.region
}

resource "aws_route53_record" "thirdparty_alias" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = "300"
  records = [var.thirdparty_alias]
}
