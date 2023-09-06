provider "aws" {
  region = var.region
}

resource "aws_lightsail_instance" "lightsail" {
  name              = var.resource_name
  availability_zone = "${var.region}a"
  blueprint_id      = "amazon_linux_2"
  bundle_id         = "nano_1_0"
  user_data         = "sudo yum install -y httpd && sudo systemctl start httpd && sudo systemctl enable httpd && echo '<h1>${var.sensitive_content}</h1>' | sudo tee /var/www/html/index.html"
}
