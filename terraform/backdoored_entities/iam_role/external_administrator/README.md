# Backdoored IAM Role

IAM role with administrative access from an external account.

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
| [aws_iam_role.exposed_asset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.admin_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account ID that will have backdoor access | `string` | `"111111111111"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to create resources in | `string` | n/a | yes |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | Convincing bucket name for the organization | `string` | n/a | yes |
| <a name="input_sensitive_content"></a> [sensitive\_content](#input\_sensitive\_content) | Content of the sensitive file to reach out to an appropriate contact. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Organization tagging strategy but should keep Creator tag for discovery later. | `map(string)` | <pre>{<br>  "Creator": "CloudCommotion"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_exposed_asset"></a> [exposed\_asset](#output\_exposed\_asset) | Backdoored IAM role ARN |
<!-- END_TF_DOCS -->
