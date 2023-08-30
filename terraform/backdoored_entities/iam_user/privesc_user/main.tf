data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.region
}

resource "random_password" "user_password" {
  length  = 16
  special = true
}

resource "aws_iam_user" "exposed_asset" {
  name = var.resource_name
  tags = var.tags
}

resource "aws_iam_access_key" "admin_user_key" {
  user = aws_iam_user.exposed_asset.name
}

resource "aws_iam_policy" "priv_esc_policy" {
  name        = var.resource_name
  description = var.sensitive_content

  policy = data.aws_iam_policy_document.priv_esc_policy.json
}

data "aws_iam_policy_document" "priv_esc_policy" {
  statement {
    actions   = ["iam:PutUserPolicy", "iam:AttachUserPolicy"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${aws_iam_user.exposed_asset.name}"]
  }

  statement {
    actions   = ["iam:CreatePolicy"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy_attachment" "potential_priv_esc_attachment" {
  user       = aws_iam_user.exposed_asset.name
  policy_arn = aws_iam_policy.priv_esc_policy.arn
}
