# Administrative IAM User

Create an IAM user with console login and access keys along with having administrative access to the account. 

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
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.admin_user_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.admin_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.admin_user_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [random_password.user_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | The AWS region to create resources in | `string` | n/a | yes |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | Convincing bucket name for the organization | `string` | n/a | yes |
| <a name="input_sensitive_content"></a> [sensitive\_content](#input\_sensitive\_content) | Content of the sensitive file to reach out to an appropriate contact. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Organization tagging strategy but should keep Creator tag for discovery later. | `map(string)` | <pre>{<br>  "Creator": "CloudCommotion"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_exposed_asset"></a> [exposed\_asset](#output\_exposed\_asset) | Name of the administrator IAM user |
<!-- END_TF_DOCS -->
