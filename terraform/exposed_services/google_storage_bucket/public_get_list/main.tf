provider "google" {
  project     = var.project_name
  region      = var.region
}

resource "google_storage_bucket" "public_all_objects" {
  name = var.resource_name
  location = "US"

  cors {
    origin = ["*"]
    method = ["GET"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_iam_binding" "public_all_objects_and_listable_bucket_acl" {
  bucket = google_storage_bucket.public_all_objects.name
  role   = "roles/storage.legacyBucketReader"
  members = [
    "allUsers",
  ]
}
