output "exposed_asset" {
  value       = aws_route53_zone.sub_zone.name
  description = "Name of the exposed asset"
}
