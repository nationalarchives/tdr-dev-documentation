# Create a new environment
This is a guide to creating a new tdr environment in a clean AWS account. This assumes you are creating one of the three environments which have already been configured in terraform (intg, staging, prod). To create a different environment, we would need additional terraform changes. 

## Create parameters in parameter store.
There are five parameters which need to be set as they can't be created or found by terraform
* /mgmt/aws_elb_account - The parent account where the logs are sent. Maintained by digital services so no way to have this in terraform
* /mgmt/cost_centre - This is a TNA property which is not available to terraform
* /mgmt/management_account - There's no way to get this while running terraform for other accounts
* /mgmt/trusted_ips - The IP list for the WAF. We could probably reconfigure this to come from `tdr-configurations` but for now, this needs to be set.
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
[tdr-api-update-prod](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Api%20Update%20Deploy/)

[tdr-checksum-prod](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Checksum%20Lambda%20Deploy)

[tdr-database-migrations-prod](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Database%20Migrations%20Deploy/)

[tdr-download-files-prod](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Download%20Files%20Deploy/)

[tdr-export-api-authoriser-prod](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Consignment%20Export%20Authoriser%20Deploy/)

[tdr-file-format-prod](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20File%20Format%20Deploy/)

[tdr-yara-av](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Antivirus%20Deploy/)

## Run the database migrations
[Migration run job](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Database%20Migrations%20Run/)

## Deploy Cloud Custodian
[Cloud Custodian deploy job](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Custodian%20Deploy/)
