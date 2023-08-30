provider "aws" {
  region = var.region
}

resource "aws_efs_file_system" "fs" {
  creation_token = "my-product"

  tags = var.tags
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.fs.id

  policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "AllowMountWriteAnywhere"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess"
    ]

    resources = [
      aws_efs_file_system.fs.arn
    ]
  }
}
