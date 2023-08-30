output "exposed_asset" {
  value       = "${aws_s3_bucket.public_bucket.arn}/${aws_s3_object.object.key}"
  description = "ARN of the public file that was created for the exercise"
}
