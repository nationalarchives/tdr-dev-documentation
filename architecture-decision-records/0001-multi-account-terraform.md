# 1. Use Terraform across multiple AWS accounts

**Date:** 2020-02-20

The actual decision was made earlier than this, between December 2019 and
January 2020.

## Context

We have created multiple AWS accounts to host the different TDR environments,
and we're happy with the decision we made during the Alpha to use Terraform to
configure the infrastructure (see [terraform.md][alpha-terraform] and
[terraform_vs_cloudformation.md][tf-vs-cf]).

The Alpha only ran in one AWS account. We used Terraform workspaces so that we
could create multiple environments if we wanted, but in the end we only used one
environment for prototyping and user testing.

In Alpha, we ran Terraform scripts from our dev machines. For Beta, we'd prefer
to run Terraform in a controlled environment like Jenkins. This has a few
advantages:

- Makes it easier to control access to production infrastructure: a developer
  can have permission to run Jenkins jobs (and therefore make
  version-controlled, peer-reviewed changes to production) without having
  credentials giving them full access to the production account
- Makes it easier to deploy changes to each environment in turn
- Provides a record of (recent) Terraform runs, and who started them

But there's a chicken-and-egg problem with running Terraform from a hosted
system like Jenkins, because it would be helpful if we could use Terraform to
create the Jenkins infrastructure itself.

[alpha-terraform]: ../technology-considerations/terraform.md
[tf-vs-cf]: ../technology-considerations/terraform_vs_cloudformation.md

## Decision

Create multiple Terraform projects, which are run in different stages:

- A backend project which is run against the management account and bootstraps
  the rest of the infrastructure. It is run from a development machine and
  creates the IAM roles and Terraform state storage (S3 and DynamoDB) that will
  be used by the environment-specific Terraform scripts. This project's own
  Terraform state is stored in a manually-created S3 bucket and DynamoDB table.
- A CI project which is run against the management account when the backend
  bootstrap script has been run. It is also run from a development machine, but
  the Terraform state is saved in the storage set up by the bootstrap script.
- An environment project which is run against each TDR environment account
  (integration, staging, production). This script is run from Jenkins.

Since the environment-specific Terraform is run from Jenkins, which is in AWS,
we can use IAM roles to give Jenkins permission to run Terraform. This means
that we don't need to generate an AWS secret key (which could be used from
outside our environment if it was stolen) for Jenkins to run Terraform.
