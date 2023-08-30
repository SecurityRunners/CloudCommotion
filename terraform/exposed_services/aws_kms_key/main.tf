provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "public_kms_policy" {
  statement {
    sid = "AllowRootAccess"

    actions = ["kms:*"]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:principaltype"
      values   = ["Account"]
    }
  }


  statement {
    sid = "AllowAllUsersAccess"

    actions = ["kms:*"]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_kms_key" "public_key" {
  description         = var.sensitive_content
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.public_kms_policy.json

  tags = var.tags
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.resource_name}"
  target_key_id = aws_kms_key.public_key.key_id
}
