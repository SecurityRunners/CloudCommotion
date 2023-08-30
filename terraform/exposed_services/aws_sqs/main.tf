provider "aws" {
  region = var.region
}

resource "aws_sqs_queue" "public_queue" {
  name = var.resource_name

  message_retention_seconds = var.message_retention
}


data "aws_iam_policy_document" "public_queue_policy" {
  statement {
    sid    = "PublicSendReceiveMessages"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "sqs:ReceiveMessage"
    ]
    resources = [aws_sqs_queue.public_queue.arn]
  }
}

resource "aws_sqs_queue_policy" "public_queue_policy_attach" {
  queue_url = aws_sqs_queue.public_queue.id
  policy    = data.aws_iam_policy_document.public_queue_policy.json
}

resource "null_resource" "send_sqs_message" {
  triggers = {
    queue_url = aws_sqs_queue.public_queue.id
  }

  provisioner "local-exec" {
    command = "aws sqs send-message --queue-url ${aws_sqs_queue.public_queue.id} --message-body '${var.sensitive_content}'"
  }
}
