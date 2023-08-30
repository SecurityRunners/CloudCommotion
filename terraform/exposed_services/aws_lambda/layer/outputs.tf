output "exposed_asset" {
  value       = aws_lambda_layer_version.lambda_layer.arn
  description = "Name of the exposed asset"
}
