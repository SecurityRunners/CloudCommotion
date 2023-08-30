provider "aws" {
  region = var.region
}

locals {
  ### Generate fake file name to ensure once found it is investigated
  # Default fake sensitive file names
  sensitive_files_generator = [
    "financial_report.pdf",
    "financial_data.xlsx",
    "personnel_records.csv",
    "decrypt_users.py",
    "revenue.docx",
    "government_ids.csv",
    "healthcare_data.json",
    "research_findings.ppt",
    "q1_earnings_report.pdf",
    "customer_ids.docx",
  ]
  # If a variable named "custom_sensitive_file" is set, use it as the sensitive file name
  sensitive_file = var.custom_sensitive_file != "" ? var.custom_sensitive_file : local.sensitive_files_generator[random_integer.index.result]
}

# Random index for 
resource "random_integer" "index" {
  min = 0
  max = length(local.sensitive_files_generator) - 1
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = var.resource_name
  tags   = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.public_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_object" "object" {
  depends_on = [aws_s3_bucket_ownership_controls.ownership]
  bucket     = aws_s3_bucket.public_bucket.bucket
  key        = local.sensitive_file

  content = var.sensitive_content
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

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}
