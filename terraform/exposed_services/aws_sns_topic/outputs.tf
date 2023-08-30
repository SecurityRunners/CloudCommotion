output "exposed_asset" {
  value       = aws_sns_topic.topic.arn
  description = "Name of the exposed asset"
}
