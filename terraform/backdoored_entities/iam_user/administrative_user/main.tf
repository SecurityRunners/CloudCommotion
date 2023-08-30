provider "aws" {
  region = var.region
}

resource "random_password" "user_password" {
  length  = 16
  special = true
}

resource "aws_iam_user" "admin_user" {
  name = var.resource_name
  tags = var.tags
}

resource "aws_iam_access_key" "admin_user_key" {
  user = aws_iam_user.admin_user.name
}

resource "aws_iam_user_policy_attachment" "admin_user_policy_attach" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}