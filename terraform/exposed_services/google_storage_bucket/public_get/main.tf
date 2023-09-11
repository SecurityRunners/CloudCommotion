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

resource "google_storage_default_object_access_control" "public_all_objects_acl" {
  bucket = google_storage_bucket.public_all_objects.name
  role   = "READER"
  entity = "allUsers"
}
