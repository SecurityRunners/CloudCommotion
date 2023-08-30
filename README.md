# Cloud Commotion

<img src=".assets/logo.png" width="200" height="200" align="right" style="border:25px solid transparent;">

You can talk the talk, but can you walk the walk? Cloud Commotion is intended to purposefully cause commotion through vulnerable or concerning infrastructure in order to test your alerting systems or lack thereof. It uses terraform to create fictitious scenarios to assess coverage of your security posture allowing you to create, deploy, and destroy the infrastructure with ease. The only question you will need answering is how long will it take for anyone to notice?

## Purpose

There is no shortage of breaches as it relates to misconfigured, vulnerable, and overly permissive infrastructure within cloud environments. Cloud Commotion simulates what occurs frequently within the industry to help better prepare you for incidents. We frequently improve on our monitoring systems while seldomly testing the effectiveness and coverage of those systems. This tool will help you setup frequent cadence to do exactly that. 

### Published Incidents

The scenarios built within the tool are inspired by actual events that occur regularly within the industry. The majority of which go unheard of and stay within the confounds of an organization. Here are just a few publicly available news stories demonstrating how one could use this tool to simulate events that have occurred in the industry.

- Exposed Jenkins box that lead to ["No Fly List" breach by CommuteAir](https://maia.crimew.gay/posts/how-to-hack-an-airline/)
- Publicly writable S3 bucket for javascript assets leading to [crypto mining on LA Times website](https://www.theregister.com/2018/02/22/la_times_amazon_aws_s3/)
- Publicly [exposed elasticsearch cluster at Amazon's Prime Video](https://techcrunch.com/2022/10/27/amazon-prime-video-server-exposed/)
- Exfiltrated cross account RDS snapshots leading to exposure of [Imperva's customer records](https://krebsonsecurity.com/2019/08/cybersecurity-firm-imperva-discloses-breach/)
- Browserstack backdoor IAM user to [BrowserStack compromised email list](https://web.archive.org/web/20141220062119/http://www.browserstack.com:80/attack-and-downtime-on-9-November)
- Exposed RDS instance lead to the [Drizly breach of 2 million user records](https://techcrunch.com/2020/07/28/drizly-data-breach/)

## About

Cloud Commotion leverages [terraform-exec](https://github.com/hashicorp/terraform-exec) to execute terraform modules to plan, create, and destroy commotion infrastructure. The terraform directory contains all the scenarios to simulate a wide variety of misconfigurations, exposed assets, and concerning infrastructure your team should be alerted on. This tool allows you to create realistic resource names, tags to the resources, and custom variables to align with your organizations current standards. You can of course take these modules and use them within your own deployment tool chain to best simulate a realistic deployment scenario as well. 

## Infrastructure

The infrastructure this tool creates to cause commotion is located within `terraform/` directory to be deployed based upon your configuration. While also allowing you to deploy with your own IaC tooling, using this tool allows you to track and manage the infrastructure associated to it's use. 

### AWS

| Title                      | Description                                                        | Terraform Module |
|----------------------------|--------------------------------------------------------------------|------------------|
| Public S3 Bucket(Get)      | Creates a public bucket with GetObject operations                  | Value 3          |
| Public S3 Bucket(Get/List) | Creates a public bucket with GetObject and ListBucket operations   | Value 6          |
| Public S3 Bucket(Write)    | Creates a public bucket with PutObject operations                  | Value 6          |
| Public S3 Object(ACL)      | Creates a private bucket with a public object                      | Value 6          |
| Public SQS Queue           | Creates a publicly accessible queue                                |                  |
| Public SNS Topic           | Creates a publicly accessible SNS topic                            |                  |
| Public Secrets Manager     | Creates a publicly acccessible secret                              |                  |
| Public Lambda Invocation   | Creates a lambda function that can be invoked by anyone            |                  |
| Public Lambda Layer        | Creates a labmda layer that is publicly accessible                 |                  |
| Public Lambda Endpoint     | Creates a publicly accessible endpoint for lambda                  |                  |
| Public Glue Policy         | Makes glue resources publicly accessible                           |                  |
| Public Glacier Vault       | Creates a publicly accessible Glacier backup vault                 |                  |
| Public EFS                 | Creates a publicly accessible EFS share                            |                  |
| Public ECR Gallery         | Creates a publicly accessible ECR Gallery registry                 |                  |
| Public ECR                 | Creates a private registry thats publicly accessible               |                  |
| Public AWS Backup Vault    | Creates a publicly accessible AWS Backup Vault                     |                  |
| Public EBS Snapshot        | Creates a public EBS snapshot                                      |                  |
| Public AMI                 | Creates a public server image                                      |                  |
| IAM Role OIDC Takeover     | Creates a IAM role that can be taken over by any GitHub Action     |                  |
| S3 Subdomain Takeover      | Creates a Route53 record that can be taken over through S3         |                  |
| EIP Takeover               | Creates a Route53 record that can be taken over through EC2        |                  |
| Third Party Takeover       | Creates a Route53 record that can be taken over through SaaS       |                  |
| Second Order Takeover      | Creates a static site where a script tag can be taken over         |                  |
| ASG RCE Takeover           | Creates a ASG that can be compromised through S3 takeover          |                  |
| Public Jenkins Instance    | Creates a publicly accessible Jenkins instance in your account     |                  |
| RDS 


### Scenarios

The infrastructure within `terraform/` are intended to simulate scenarios that are likely to trigger alerting systems while also helping you identify gaps. The scenarios are essentially a list of table top exercises you can perform at will and create safe fictitious holes in your architecture.

- Backdoors
    - Cross Account Administrative Role
    - Cross Account with Priviledge Escalation Role
    - IAM User with Administrative Permissions with Console Sign In
    - IAM User with Priviledge Escalation with Console Sign In
    - Exposed API Gateway with Administrative Functionality(TODO)
    - Cross Account ECR Policy with Ability to Overwrite Image(TODO)
    - Cross Account Lambda Function with Administrative Permissions(TODO)
    - Variety of Scenarios for Cross Account Administrative Functions(TODO)
    - Exfiltrating Service Snapshots(TODO)
        - AMI
        - RDS(TODO)
        - Redshift(TODO)
- Exposed Assets
    - Exposed fictitious EC2 Instance(TODO)
        - Exposed Jenkins(TODO)
        - Exposed custom flag(TODO)
    - Exposed API Gateway(TODO)
    - Exposed Unauthenticated Kubernetes API Actions(TODO)
    - Exposed ECS Cluster(TODO)
    - Exposed Lightsail Instance(TODO)
    - S3 CloudFront static site sensitive file(TODO)
    - Public Snapshots
        - Public EBS Snapshot
        - Public AMI
        - ?
- Exposed Services
    - Variety of Public S3 Bucket/Object scenarios
        - Public Bucket Policy (List + Get)
        - Public Bucket Policy (Get)
        - Public Object ACL
    - Public SQS Queue
    - Public Lambda
        - Lambda Layer
        - Invoke
        - Endpoint(TODO)
    - Public Elastic Docker/Container Registry
        - Public Registry
        - Private Registry made public
    - Public KMS Key
    - Public AWS Backup
    - Public EFS(NFS)
    - Public Glacier
    - Public IAM Role
    - Public Secrets Manager
    - Public CloudWatch Logs(?)
    - Public EventBridge(TODO)
    - Public MediaStore(TODO)
    - Public Elasticsearch/Opensearch(TODO)
    - Public Glue
    - Public SNS(TODO)
    - Public SES(TODO)
- Misconfigurations
    - RCE S3 Takeover Instance Metadata(TODO)
    - Plaintext Secrets in a variety of locations(TODO)
        - Instance metadata
        - Environment variables
    - Subdomain takeovers
        - EIP Takeover
        - Public IP Takeover
        - S3 Takeover
        - Third party service takeover
        - Second order subdomain takeover
    - GitHub Actions IAM OIDC takeover
- Destructive
    - Disable Eventbridge notifications(TODO)
    - Disable Security Services(TODO)
    - Ransomware for S3(TODO)

### Variables

These are vaiables that are used across all the scenarios to account for global namespaces, custom flags to alert the responders, and tags to accomodate for tagging strategies. 

- Resource name, for example `piedpiper-static-assets` for `resource_name` variable, to create a ficticios asset that can realistically sit alongside your infrastructure without raising a flag to curious onlookers
- Custom sensitive content, for example `This file was created through cloudcommotion, please report this asset to your security team` for `custom_sensitive_content` variable, to allow for a way for an unsuspecting incident responders to become aware of the drill once identified
- Tags is an optional variable, such as `Creator = cloudcommotion` for `tags` as type `map(string)`, to ensure your asset does not get caught up in unrelated tagging enforcement infrastructure
- Region, such as the default `us-east-1` for `region` variable, to allow you to switch up regions

#### Optional Variables

- Custom sensitive file, for example `users_table_20230910.csv` for `custom_sensitive_file`, for S3 related scenarios

### Validation

- Create documentation for the module `terraform-docs markdown table . --output-file README.md`
- Format the terraform `terraform fmt .`


## TODO

- Determine flags
- Destroy without variables?
- Get variables from config and if not then flags? `config.GetConfig().Variables.ResourceName`
- Store variables for later destory somehow?

### Configuration

- Default configuration requires no parameters defaults to easy + random pet name
- Required flag is just playbook/module/difficulty
- Recommended flags are region, resource name(s), sensitive message, 



### Configuration File

- Provider
    - Might be important later at least for random region selection for multi-cloud
- Region
    - Random or a valid region
- Module
    - Name
        - Name of the terraform module to execute
    - terraform_dir
        - Directory of the terraform to execute
    - Variables
        - Maybe?
- Variables
    - resource_name
        - Name of the resource as must be unique in some global namespaces(s3) as well as more convincing
    - sensitive_content
        - Allows for a flag to be embedded within the file that might be useful, maybe should not be in the module itself but in code?
    - tags
        - Tags for the created resource

### Flags

- Region
- Terraform Module
- Config file
- Variables - If this is a flag destroying might be a bit difficult unless storing a file?
    - Flag
    - Resource name


https://mystic0x1.github.io/posts/methods-to-backdoor-an-aws-account/
https://dagrz.com/writing/aws-security/getting-into-aws-security-research/

.terraform/
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.backup
