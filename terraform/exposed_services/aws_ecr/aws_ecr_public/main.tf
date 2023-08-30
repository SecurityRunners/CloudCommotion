provider "aws" {
  region = var.region
}

resource "aws_ecr_repository" "public_repo" {
  name = var.resource_name

  tags = var.tags
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "AllowPushPull"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
  }
}


resource "aws_ecr_repository_policy" "my_repo_policy" {
  repository = aws_ecr_repository.public_repo.name
  policy     = data.aws_iam_policy_document.policy.json
}
