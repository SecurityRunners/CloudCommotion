output "exposed_asset" {
  value       = google_storage_bucket.public_all_objects.name
  description = "Name of the exposed asset"
}
