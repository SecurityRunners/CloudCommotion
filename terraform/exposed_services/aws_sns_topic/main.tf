provider "aws" {
  region = var.region
}

resource "aws_sns_topic" "topic" {
  name = var.resource_name

  display_name = var.sensitive_content

  tags = var.tags
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions   = ["SNS:Publish", "SNS:Subscribe", "SNS:Receive"]
    effect    = "Allow"
    resources = [aws_sns_topic.topic.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_sns_topic_policy" "public_topic_policy" {
  arn    = aws_sns_topic.topic.arn
  policy = data.aws_iam_policy_document.policy.json
}
