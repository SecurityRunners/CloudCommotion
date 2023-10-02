# Github Actions OIDC Misconfiguration

This module creates a GitHub OIDC connector with AWS that is misconfigured to allow any GitHub action to assume it. This research has recently emerged by [Tinder Security Labs](https://medium.com/tinder/identifying-vulnerabilities-in-github-actions-aws-oidc-configurations-8067c400d5b8) in which major organizations were impacted through a simple misconfiguration.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_id_list"></a> [client\_id\_list](#input\_client\_id\_list) | n/a | `list(string)` | <pre>[<br>  "https://github.com/SecurityRunners"<br>]</pre> | no |
| <a name="input_openid_url"></a> [openid\_url](#input\_openid\_url) | Custom variables | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to create resources in | `string` | n/a | yes |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | Convincing bucket name for the organization | `string` | n/a | yes |
| <a name="input_sensitive_content"></a> [sensitive\_content](#input\_sensitive\_content) | Content of the sensitive file to reach out to an appropriate contact. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Organization tagging strategy but should keep Creator tag for discovery later. | `map(string)` | <pre>{<br>  "Creator": "CloudCommotion"<br>}</pre> | no |
| <a name="input_thumbprint_list"></a> [thumbprint\_list](#input\_thumbprint\_list) | n/a | `list(string)` | <pre>[<br>  "6938fd4d98bab03faadb97b34396831e3780aea1",<br>  "1c58a3a8518e8759bf075b76b750d4f2df264fcd"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_exposed_asset"></a> [exposed\_asset](#output\_exposed\_asset) | Name of the exposed asset |
<!-- END_TF_DOCS -->
