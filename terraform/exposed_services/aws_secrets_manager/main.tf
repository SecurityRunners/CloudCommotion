provider "aws" {
  region = var.region
}

resource "aws_secretsmanager_secret" "secret" {
  name = var.resource_name

  tags = var.tags
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "AllowPublicAccessToSecret"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [aws_secretsmanager_secret.secret.arn]
  }
}

resource "aws_secretsmanager_secret_policy" "public_policy" {
  secret_arn = aws_secretsmanager_secret.secret.arn
  policy     = data.aws_iam_policy_document.policy.json
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.sensitive_content
}
