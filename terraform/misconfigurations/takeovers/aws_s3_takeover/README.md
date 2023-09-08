# S3 Subdomain Takeover

This module creates a route53 record to create a subdomain takeover that can be taken over by creating your S3 bucket. This module chooses to create a bucket prior to and then delete to ensure it is vulnerable. Avoid using this on customer facing domains. 

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.12.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.website_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.static_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_website_configuration.static_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [null_resource.bucket_deletion](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name used for the takeover | `string` | `"www.example.com"` | no |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | The hosted zone ID for the domain name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to create resources in | `string` | n/a | yes |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | Convincing bucket name for the organization | `string` | n/a | yes |
| <a name="input_sensitive_content"></a> [sensitive\_content](#input\_sensitive\_content) | Content of the sensitive file to reach out to an appropriate contact. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Organization tagging strategy but should keep Creator tag for discovery later. | `map(string)` | <pre>{<br>  "Creator": "CloudCommotion"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_exposed_asset"></a> [exposed\_asset](#output\_exposed\_asset) | Name of the exposed asset |
<!-- END_TF_DOCS -->
