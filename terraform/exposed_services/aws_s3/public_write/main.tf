provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = var.resource_name
  tags   = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

data "aws_iam_policy_document" "public_policy" {
  statement {
    sid    = "PublicPutObject"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.public_bucket.id}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.public_bucket.id
  policy = data.aws_iam_policy_document.public_policy.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.public_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.public_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}
