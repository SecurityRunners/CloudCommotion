provider "aws" {
  region = var.region
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "index.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  tags = var.tags

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "public_lambda_invoke_policy" {
  statement {
    sid    = "PublicInvoke"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.public_lambda.arn]
  }
}

resource "aws_lambda_permission" "public_invoke_permission" {
  statement_id  = "AllowInvokeFromAnyone"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.public_lambda.function_name
  principal     = "*"
  source_arn    = aws_lambda_function.public_lambda.arn
}

resource "aws_lambda_function" "public_lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = var.resource_name
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  tags          = var.tags

  environment {
    variables = {
      SENSITIVE_CONTENT = var.sensitive_content
    }
  }
}
