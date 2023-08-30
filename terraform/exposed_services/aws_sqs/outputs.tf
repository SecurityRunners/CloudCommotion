output "exposed_asset" {
  value       = aws_sqs_queue.public_queue.arn
  description = "Exposed SQS queue"
}
