output "exposed_asset" {
  value       = aws_ami.xacct_ami.id
  description = "Name of the exposed asset"
}
