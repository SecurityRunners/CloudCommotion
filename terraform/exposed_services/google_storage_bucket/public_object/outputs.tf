output "exposed_asset" {
  value       = google_storage_bucket.public_single_object.name
  description = "Name of the exposed asset"
}
