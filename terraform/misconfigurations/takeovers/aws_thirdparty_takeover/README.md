# Third Party Takeover

This module creates a route53 cname alias to a third party which may be vulnerable to takeovers. The default example is a wordpress.com subdomain takeover scenario.

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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.thirdparty_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name used for the takeover | `string` | `"www.example.com"` | no |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | The hosted zone ID for the domain name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to create resources in | `string` | n/a | yes |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | Convincing bucket name for the organization | `string` | n/a | yes |
| <a name="input_sensitive_content"></a> [sensitive\_content](#input\_sensitive\_content) | Content of the sensitive file to reach out to an appropriate contact. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Organization tagging strategy but should keep Creator tag for discovery later. | `map(string)` | <pre>{<br>  "Creator": "CloudCommotion"<br>}</pre> | no |
| <a name="input_thirdparty_alias"></a> [thirdparty\_alias](#input\_thirdparty\_alias) | The alias of the site that does not exist | `string` | `"thissitedefinetelydoesnotexist.wordpress.com"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_exposed_asset"></a> [exposed\_asset](#output\_exposed\_asset) | Name of the exposed asset |
<!-- END_TF_DOCS -->
