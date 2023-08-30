provider "aws" {
  region = var.region
}

resource "null_resource" "layer_zip" {
  provisioner "local-exec" {
    command = <<EOL
      echo "${var.sensitive_content}" > layer.txt
      zip layer.zip layer.txt
EOL
  }

  triggers = {
    content = var.sensitive_content
  }
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename            = "layer.zip"
  layer_name          = var.resource_name
  compatible_runtimes = ["nodejs14.x"]

  depends_on = [null_resource.layer_zip]
}

resource "aws_lambda_layer_version_permission" "lambda_layer_permission" {
  depends_on     = [aws_lambda_layer_version.lambda_layer]
  layer_name     = aws_lambda_layer_version.lambda_layer.layer_name
  version_number = aws_lambda_layer_version.lambda_layer.version
  principal      = "*"
  action         = "lambda:GetLayerVersion"
  statement_id   = var.resource_name
}

# Remove the layer once complete
resource "null_resource" "remove_zip" {
  provisioner "local-exec" {
    command = "rm -f layer.zip layer.txt"
  }

  depends_on = [aws_lambda_layer_version.lambda_layer]
}
