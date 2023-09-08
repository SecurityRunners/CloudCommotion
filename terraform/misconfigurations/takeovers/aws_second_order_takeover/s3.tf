resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.resource_name
  tags   = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_website_configuration" "static_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = "index.html"
  }
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid       = "PublicReadGetObject"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.resource_name}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "object" {
  bucket       = aws_s3_bucket.s3_bucket.bucket
  key          = "index.html"
  content_type = "text/html"
  content      = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://${var.resource_name}-static.s3.amazonaws.com/script.js"></script>
    <!-- ${var.sensitive_content} -->
    <title>Did your cat step on your keyboard?</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            text-align: center;
            background-color: #f4f4f4;
        }
        h1 {
            color: #333;
        }
        p {
            color: #666;
        }
    </style>
</head>
<body>
    <h1>Welcome to My Vulnerable Page!</h1>
    <p>This page is vulnerable to second order subdomain takeover in the script tag.</p>
    <p>${var.sensitive_content}</p>
    <iframe src="https://giphy.com/embed/ICOgUNjpvO0PC" width="480" height="359" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/cat-humour-funny-ICOgUNjpvO0PC">via GIPHY</a></p>
</body>
</html>
EOF
}

# Temporary bucket to host scripts that will be deleted to ensure it's not already owned
resource "aws_s3_bucket" "static_bucket" {
  bucket = "${var.resource_name}-static"

  tags = var.tags
}

resource "null_resource" "bucket_deletion" {
  depends_on = [aws_s3_bucket.static_bucket]

  provisioner "local-exec" {
    command = "aws s3 rb s3://${aws_s3_bucket.static_bucket.bucket} --force"
  }
}
