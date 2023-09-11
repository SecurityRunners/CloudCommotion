provider "google" {
  project     = var.project_name
  region      = var.region
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

resource "random_integer" "index" {
  min = 0
  max = length(local.sensitive_files_generator) - 1
}

resource "google_storage_bucket" "public_single_object" {
  name     = var.resource_name
  location = "US"

  cors {
    origin = ["*"]
    method = ["GET"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_object" "public_single_object_content" {
  name    = local.sensitive_file
  bucket  = google_storage_bucket.public_single_object.name
  content = var.sensitive_content
}

resource "google_storage_object_access_control" "public_single_object_acl" {
  object = google_storage_bucket_object.public_single_object_content.name
  bucket = google_storage_bucket.public_single_object.name
  role   = "READER"
  entity = "allUsers"
}
