output "exposed_asset" {
  value       = aws_lambda_function.public_lambda.arn
  description = "Exposed Lambda invoke function ARN"
}
