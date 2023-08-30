provider "aws" {
  region = var.region
}

resource "aws_backup_global_settings" "settings" {
  global_settings = {
    "isCrossAccountBackupEnabled" = "true"
  }
}

resource "aws_backup_vault" "vault" {
  name = var.resource_name

  tags = var.tags
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "backup:CopyIntoBackupVault",
    ]

    resources = [aws_backup_vault.vault.arn]
  }
}

resource "aws_backup_vault_policy" "policy" {
  backup_vault_name = aws_backup_vault.vault.name
  policy            = data.aws_iam_policy_document.policy.json

  depends_on = [aws_backup_global_settings.settings]
}
