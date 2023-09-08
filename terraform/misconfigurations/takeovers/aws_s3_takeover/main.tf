provider "aws" {
  region = var.region
}

# Create an S3 bucket for static website hosting
resource "aws_s3_bucket" "static_bucket" {
  bucket = var.resource_name

  tags = var.tags
}

resource "aws_s3_bucket_website_configuration" "static_bucket" {
  bucket = aws_s3_bucket.static_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_route53_record" "website_record" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_s3_bucket_website_configuration.static_bucket.website_domain
    zone_id                = aws_s3_bucket.static_bucket.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "null_resource" "bucket_deletion" {
  depends_on = [aws_s3_bucket.static_bucket]

  provisioner "local-exec" {
    command = "aws s3 rb s3://${aws_s3_bucket.static_bucket.bucket} --force"
  }
}
