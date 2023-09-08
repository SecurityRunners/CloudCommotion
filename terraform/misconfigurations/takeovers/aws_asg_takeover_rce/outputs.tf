output "exposed_asset" {
  value       = aws_autoscaling_group.asg.arn
  description = "Name of the exposed asset"
}
