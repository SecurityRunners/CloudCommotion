provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "glue:*",
    ]
    resources = ["arn:aws:glue:${var.region}:${data.aws_caller_identity.current.id}:*"]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

resource "aws_glue_resource_policy" "policy" {
  policy = data.aws_iam_policy_document.policy.json
}
