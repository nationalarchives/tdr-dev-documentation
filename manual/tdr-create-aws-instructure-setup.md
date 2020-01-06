# TDR AWS Infrastructure Setup

This is a guide for the steps necessary to setup the AWS infrastructure to support the TDR application from scratch.

The guide is based on the following design:
* There will be three TDR environments:

  * Integration (intg)
  * Staging (staging)
  * Production (prod)
  
* There will multiple AWS accounts to host the different TDR environments:

  * Integration AWS account: host the TDR integration environment
  * Production AWS account: host the TDR staging *and* production environments
  * Management AWS account: to manage the TDR environment accounts

## A. AWS Accounts Setup

1. Set up a TDR "management" AWS account.

   This account will be used to run the AWS resourcing operations using Terraform, and Jenkins builds

2. Set up individual TDR "environment" AWS accounts to represent the different application environments required. 

   For example setup AWS accounts for "intg", "staging" and "production" environments
   
3. Add the TDR "environment" AWS account ids to the parameter store in the TDR "management" AWS account with the following names:

   * Integration Account: /mgmt/intg_account
   * Staging Account: /mgmt/staging_account
   * Production Account: /mgmt/prod_account

## B. Setup Terraform Backend

1. Add a "bootstrap" Terraform backend to store the state of the Terraform backend using the AWS console in the TDR AWS **management** account:

   (a) Create s3 bucket: tdr-bootstrap-terraform-state
   
      Ensure the s3 bucket has the following tags:
      
      * Owner: TDR Backend
      * Terraform: false
      * Name: TDR Bootstrap Terraform State
       
      This will store the state of the Terraform for the backend during development, and allow sharing of the state between multiple developers
   
   (b) Create DynamoDb table: tdr-bootstrap-terraform-statelock
   
      Ensure the DyanamoDb table has the following tags:
      
      * Owner: TDR Backend
      * Terraform: false
      * Name: TDR Bootstrap Terraform State Lock Table
   
      This will provide locking of the s3 bucket to prevent conflicts when multiple developers are working.
      
   For further information on setting up Terraform s3 backend, see here: https://www.terraform.io/docs/backends/types/s3.html

2. Setup the Terraform Backend project in the TDR AWS management account: https://github.com/nationalarchives/tdr-terraform-backend/blob/master/README.md

## C. Setup Jenkins

Setup Jenkins project in the TDR AWS management account: https://github.com/nationalarchives/tdr-jenkins/blob/master/README.md

## D. Setup Individual TDR Environment

Setup the Terraform Environments project: https://github.com/nationalarchives/tdr-terraform-environments/blob/master/README.md