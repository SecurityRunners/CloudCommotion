output "exposed_asset" {
  value       = aws_lambda_function_url.lambda_function_url.function_url
  description = "Name of the exposed asset"
}
