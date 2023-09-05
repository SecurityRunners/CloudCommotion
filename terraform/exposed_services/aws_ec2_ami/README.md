# Public AMI

Creates an EBS volume, takes a snapshot, creates an AMI, and makes it public.

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
| [aws_ami.public_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ami) | resource |
| [aws_ami_launch_permission.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ami_launch_permission) | resource |
| [aws_ebs_snapshot.snapshot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_snapshot) | resource |
| [aws_ebs_volume.volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use for the EC2 instance | `string` | `"t3.micro"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to create resources in | `string` | n/a | yes |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | Convincing bucket name for the organization | `string` | n/a | yes |
| <a name="input_sensitive_content"></a> [sensitive\_content](#input\_sensitive\_content) | Content of the sensitive file to reach out to an appropriate contact. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Organization tagging strategy but should keep Creator tag for discovery later. | `map(string)` | <pre>{<br>  "Creator": "CloudCommotion"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_exposed_asset"></a> [exposed\_asset](#output\_exposed\_asset) | Name of the exposed asset |
<!-- END_TF_DOCS -->
