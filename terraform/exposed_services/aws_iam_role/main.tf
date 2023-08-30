provider "aws" {
  region = var.region
}

data "aws_iam_policy_document" "wildcard_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "public_role" {
  name               = var.resource_name
  assume_role_policy = data.aws_iam_policy_document.wildcard_assume_role.json

  tags = var.tags
}

data "aws_iam_policy_document" "get_caller_identity_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name        = var.resource_name
  description = var.sensitive_content
  policy      = data.aws_iam_policy_document.get_caller_identity_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "example_attach" {
  role       = aws_iam_role.public_role.name
  policy_arn = aws_iam_policy.policy.arn
}
