provider "aws" {
  region = var.region
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "index.py"
  output_path = "lambda_function_payload.zip"
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

resource "aws_lambda_function_url" "lambda_function_url" {
  function_name      = aws_lambda_function.public_lambda.arn
  authorization_type = "NONE"
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
