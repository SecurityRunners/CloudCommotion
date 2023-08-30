provider "aws" {
  region = var.region
}

resource "aws_iam_role" "exposed_asset" {
  name = var.resource_name
  tags = var.tags

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "admin_full_access" {
  role       = aws_iam_role.exposed_asset.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
