provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_glacier_vault" "archive" {
  name = var.resource_name

  access_policy = data.aws_iam_policy_document.policy.json

  tags = var.tags
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "glacier:InitiateJob",
      "glacier:GetJobOutput"
    ]

    resources = [
      "arn:aws:glacier:${var.region}:${data.aws_caller_identity.current.account_id}:vaults/${var.resource_name}"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
