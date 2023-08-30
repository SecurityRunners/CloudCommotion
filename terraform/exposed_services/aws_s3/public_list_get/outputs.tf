output "exposed_asset" {
  value       = aws_s3_bucket.public_bucket.arn
  description = "Name of the public bucket that was created for the exercise"
}
