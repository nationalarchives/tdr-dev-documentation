# Create a new environment
This is a guide to creating a new tdr environment in a clean AWS account. This assumes you are creating one of the three environments which have already been configured in terraform (intg, staging, prod). To create a different environment, we would need additional terraform changes (WIP notes on construction of a brand new environment can be found [here](#creating-a-brand-new-environment-in-a-new-aws-account)).

## Create parameters in parameter store.
There are five parameters which need to be set as they can't be created or found by terraform
* /mgmt/aws_elb_account - The parent account where the logs are sent. Maintained by digital services so no way to have this in terraform
* /mgmt/cost_centre - This is a TNA property which is not available to terraform
* /mgmt/management_account - There's no way to get this while running terraform for other accounts
* /environmentname/frontend/auth/thumbprint - The thumbprint used for the IAM external provider.

### External provider thumbprint
The OIDC provider thumbprint comes from an AWS provided certificate and is the same for anything using their certificates in a region.
You can find it by running:

`openssl s_client -servername oidc.eks.eu-west-2.amazonaws.com -showcerts -connect oidc.eks.eu-west-2.amazonaws.com:443`

Copy the final certificate that is output starting from `-----BEGIN CERTIFICATE-----` up to `-----END CERTIFICATE-----` inclusive and write to a file certificate.crt.

`openssl x509 -in certificate.crt -fingerprint -noout`

Remove the colons from the output of this command and put it in lower case, this is your thumbprint.

## Run terraform
`terraform workspace select environmentname`

`terraform init`

`terraform apply -var 'tdr_account_number=account_number`

### Update parameters in the parameter store
The following parameters are added by Terraform, but have placeholder values, because the values are not available to Terraform.

The placeholder values should be updated with the correct values in each case.

* /environmentname/keycloak/govuk_notify/api_key - the placeholder value should be replaced with the relevant GovUK Notify API key from the GovUK Notify service for the environment
* /environmentname/keycloak/govuk_notify/template_id - the placeholder value should be replaced with the relevant GovUK Notify template id from the GovUK Notify service for the environment

## Deploy ECR images
All of these jenkins jobs need to be deployed with the stage set to the environment you are deploying and the version set to the latest version of the released code.

[auth-server](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Auth%20Server%20Deploy/)

[consignment-api](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Consignment%20API%20Deploy/)

[consignment-export](https://jenkins.tdr-management.nationalarchives.gov.uk/job/Consignment%20Export%20Deploy/)

[file-format-build](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20File%20Format%20Build/) This will also run the file format build task to install droid on the EFS volume.

[transfer-frontend](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Front%20End%20Deploy/)

[yara-dependencies,yara-rules and yara](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Antivirus%20Build/)

## Deploy the lambdas
[tdr-api-update](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Api%20Update%20Deploy/)

[tdr-checksum](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Checksum%20Lambda%20Deploy)

[tdr-database-migrations](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Database%20Migrations%20Deploy/)

[tdr-download-files](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Download%20Files%20Deploy/)

[tdr-export-api-authoriser](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Consignment%20Export%20Authoriser%20Deploy/)

[tdr-file-format](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20File%20Format%20Deploy/)

[tdr-yara-av](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Antivirus%20Deploy/)

[tdr-create-db-users](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Create%20DB%20User%20Deploy/)

## Run the user creation Lambdas

Run the following Lambdas:

* tdr-create-db-users
* tdr-create-keycloak-db-user

From the command line run the following commands. Note need to ensure have credentials for the environment to run Lambdas:

* `aws lambda invoke --function-name tdr-create-db-users-$environment-name`
* `aws lambda invoke --function-name tdr-create-keycloak-db-user-$environment-name`

## Run the database migrations
[Migration run job](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Database%20Migrations%20Run/)

## Deploy Cloud Custodian
[Cloud Custodian deploy job](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Custodian%20Deploy/)

## Creating a brand new environment in a new AWS account

> **Note** The below are notes on experimental WIP attempts to spin up a new environment. They will be updated as the exercise progresses.

### Account Setup
Ask an organisational admin to set up a new account. In order to successfully run the backend terraform, you will need to update the ACL size quota from the [Service Quota dashboard](https://us-east-1.console.aws.amazon.com/servicequotas/home/dashboard). Go to _Identity Access and Management_ and set _Role trust policy length_ to 4096. This should be automatically approved.

### Backend

The first terraform that needs to be run to set up a new environments is housed in [tdr-terraform-backend](https://github.com/nationalarchives/tdr-terraform-backend). This bootstraps resources required to run terraform for different environments, including IAM roles and permissions and s3 buckets and DynamoDB stores for tracking and managing terraform state. It is run from the command line on developer machines. There is a single `default` workspace from which resources for all environments are created.

Before running the terraform, add an AWS sso profile for the `env` account to your `~/.aws/config` file, eg:

```
[profile env]
sso_start_url  = <start_url>
sso_region     = eu-west-2
sso_account_id = <account number>
sso_role_name  = AdministratorAccess
region         = eu-west-2
output         = json
```
Add a new _env_ provider below an existing provider in `root.tf`, eg
```
provider "aws" {
  alias   = "env"
  region  = "eu-west-2"
  profile = "env"
}
```
> **Note** Your `AWS_PROFILE` should still be set as `management` in the command line, the provider addition is for use by the terraform itself

Make copies of the following resource blocks with arguments adjusted for your new environment:
- `<env>_account_parameters`
- `<env>_specific_permissions`
- `<env>_environment_roles`
- `github_terraform_assume_role_<env>`
- `github_cloudwatch_terraform_plan_outputs_<env>`

### GitHub
If you wish to make use of GitHub actions for your environment, you will need to run [tdr-terraform-github](https://github.com/nationalarchives/tdr-terraform-github) in a new _env_ workspace. Add a provider in `root_provider.tf` for your environment (as in the code snippet provided in the backend instructions above).

A number of code insertions will be required:
- Copy over an environment in `root_github_environment.tf` by duplicating `<env>_github_iam_roles_policies`
- Add appropriate locals for `<env>_apply`, `<env>_account_id` and `<env>_environment`
- Add `<env>` to the `account_numbers` configuration map
- Add `<env>` to the `contains` clause of `e2e_testing_role_arn` and `internal_buckets_kms_key_alias` in `da-terraform-configurations` config

### Accounts
Next, run the terraform in [tdr-aws-accounts](https://github.com/nationalarchives/tdr-aws-accounts), which configures logging and security infrastructure according to centralised organisational logic. You can either do this from the command line or, if you have run the GitHub terraform in the previous step, run from the supplied GitHub Action, following the instructions in the README.

- The external provider in the trust policy for the terraform role created by the backend in the new account. The role is `TDRGithubTerraformAssumeRole<env>`
- `<env>` will need to be added to `da-terraform-configurations`, as well as as an entry to the local environment full name map
- You may need to wait for ses domain identity email verification to complete (will also need to contact a member of `tdr-secops` to approve the email)

> **Note** Final stages of this terraform still timing out at time of writing. Additional permissions will also need to be added to update the password policy

### Environments

The final set of terraform that needs to be run can be found in [tdr-terraform-environments](https://github.com/nationalarchives/tdr-terraform-environments).

- Create `env` workspace in `tdr-terraform-environments` and select it
- Set the `TF_VAR_tdr_account_number` env var as your new account id and `AWS_PROFILE` as `management`
- Add a `test` entry to the `locals.account_numbers` map

#### SSM Parameters
There are a range of SSM parameters that will need to be added to the AWS parameter store for your new account on first running the environments terraform in your workspace.
> The Contents column of the below table contains some WIP comments on possible obsolescence, potential removals, and workarounds for the purposes of getting up and running. Further along in the spike, some of these may be removed as changes are committed to the main branch

| Parameter path                                                                                                                                         | Type         | Contents                                                                                                                                                                                                                                                                                                                                                                                        |
|--------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| /mgmt/management_account                                                                                                                               | String       | Management account number. This can be be replaced with the `da-terraform-configurations` entry                                                                                                                                                                                                                                                                                                 |
| /mgmt/aws_elb_account                                                                                                                                  | SecureString | Account number for AWS ELB account for the eu-west-2 region. We can probably eliminate or hardcode this in future                                                                                                                                                                                                                                                                               |
| /mgmt/cost_centre                                                                                                                                      | String       | This can be deleted, as it can be accessed from the configurations module                                                                                                                                                                                                                                                                                                                       |
| /env/cloudfront_private_key_pem                                                                                                                        | SecureString | Create a pair following [these](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html#private-content-creating-cloudfront-key-pairs) instructions. Copy the private key to the parameter store (without comments beginning and end) and the private key to `sign_cookies_public_key_<env>.pem` in `cloudfront` within `tdr-terraform-modules` |
| /mgmt/slack_success_workflow, /mgmt/slack_failure_workflow, /mgmt/slack_e2e_success_workflow, /mgmt/slack_e2e_failure_workflow                         | SecureString | No longer appear to be in use, can be deleted                                                                                                                                                                                                                                                                                                                                                   |
| /mgmt/workflow_pat                                                                                                                                     | SecureString | Workflow PAT, likely deprecated, can be copied over from `intg`                                                                                                                                                                                                                                                                                                                                 |
| /env/slack/notification/webhook, /env/slack/judgment/webhook, /env/slack/standard/webhook, /env/slack/notifications/webhook, /env/slack/export/webhook | SecureString | These don't tend to vary by environment, with the sending/not sending logic delegated to the notifications lambda. We may want to host these in the management account in future Can be set as blank in initial run.                                                                                                                                                                            |
| /env/keycloak/govuk_notify/api_key                                                                                                                     | SecureString | Can leave blank at outset- should be supplied if intending to use the GOVUK notification service (a new environment will need setting up in GOVUK Notify if so)                                                                                                                                                                                                                                 |
| /env/keycloak/backend_checks_client/secret                                                                                                             | SecureString | Can be left blank will be populated when the keycloak secrets rotation lambda runs                                                                                                                                                                                                                                                                                                              |
| /env/admin_role                                                                                                                                        | SecureString | SSO AdministratorAccess role (search in new environment iam console for arn)                                                                                                                                                                                                                                                                                                                    |
| /env/export_role                                                                                                                                       | SecureString | SSO TDR-Export role (search in new environment iam console for arn)                                                                                                                                                                                                                                                                                                                             |

#### Config
> **Note** Value notes suggest defaults during experimenting. For non transient environments, these will need to be committed to source control

| Module | Variable                                             | Value                                                                                                                                                             |
|--------|------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| dr2    | account_numbers                                      | Set to same as intg, eg: dr2_account_number = module.dr2_configuration.account_numbers[local.environment == "env" ? "intg": local.environment]                    |
| dr2    | copy_files_role                                      | Set to same as intg, eg: dr2_account_number = module.dr2_configuration.account_numbers[local.environment == "env" ? "intg": local.environment]                    |
| talend | talend_export_role_arn                               | Set to same as intg, eg: dr2_account_number = module.dr2_configuration.account_numbers[local.environment == "env" ? "intg": local.environment]                    |
| tdr    | e2e_testing_role_arn, internal_buckets_kms_key_alias | Add `env` to the `contains` clause of the `e2e_testing_role_arn` and `internal_buckets_kms_key_alias` map entries in the `da-terraform-configurations` tdr config |
| tdr    | da_reference_generator_url                           | Can be set to empty string for initial terraform run                                                                                                              |

