provider "aws" {
  region = var.region
}

# aws iam open id connect provider github
resource "aws_iam_openid_connect_provider" "provider" {
  url             = var.openid_url
  client_id_list  = var.client_id_list
  thumbprint_list = var.thumbprint_list

  tags = var.tags
}


resource "aws_iam_role" "role" {
  name        = var.resource_name
  description = var.sensitive_content

  assume_role_policy = data.aws_iam_policy_document.document.json

  tags = var.tags
}

# Misconfigured policy document
data "aws_iam_policy_document" "document" {
  statement {
    sid     = "AssumeRoleFromOIDCProvider"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid     = "GetCallerIdentity"
    effect  = "Allow"
    actions = ["sts:GetCallerIdentity"]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name        = var.resource_name
  description = var.sensitive_content
  policy      = data.aws_iam_policy_document.policy.json

  tags = var.tags
}
