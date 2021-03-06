# Terraform Documentation

* Prototype Project:
  * **Master Branch**: https://github.com/nationalarchives/tdr-prototype-terraform (*"stateful" repository structure to manage AWS environments*)
  * **Workspaces Branch**: https://github.com/nationalarchives/tdr-prototype-terraform/tree/workspaces (*Terraform workspaces to manage AWS environments*)

## Recommendations

These are based on discussions with Digital Services team and their experiences with using Terraform:
* **Make use of Terraform workspaces**: This was not something that Digital Services did as they were not aware of them. Terraform workspaces provide better management of different environments and their state, then having different directories to define different environments.
* **Testing of Terraform**: This is not something that Digital Services do. There is no reason to adopt testing, though further investigation is needed into the testing frameworks available for Terraform, and whether this will bring any benefits
* **Running Terraform from developer local environments**: This is the approach that Digital Services take. Further investigation should be done as to whether there is any advantages to running Terraform on Jenkins (or other CI/CD client)
* **Project Structure Using "Root"**: Create the Terraform project with a "root" which then calls separate modules as needed. Digital Services took a different route, with having individual "roots" for each of the Terraform modules.

Teraform recommended practices: https://www.terraform.io/docs/enterprise/guides/recommended-practices/index.html

## Comparison of Terraform and AWS Cloudformation

AWS CloudFormation | Terraform
--- | ---
Initial release February 2011| Initial release July 2014
Proprietary| Open source
No experience within the team | Some experience within the team
Not currently used within TNA | Used by Digital Services
Specific to AWS | Cloud provider agnostic
Only manage elements of infrastructure specific to AWS | Allows for the management of entire infrastructure
Planning and execution combined so developer needs to mentally envisage the changes before commiting | Separate out "planning" infrastructure from execution
Major users: Expedia | Major users: Starbucks, Uber, Slack

Terraform provides a useful comparison with other infrastructure tools here: https://www.terraform.io/intro/vs/index.html

## Project Structure

The prototype project consists of two branches that show two possible approaches to the management of AWS environments using Terraform.

The "master" branch shows the approach of using separate folders, and Terraform scripts to create different AWS environments. This is the approach taken by Digital Services

The "workspaces" branch shows the approach of using Terraform workspaces to create different AWS environments.

Both approaches show how to support multiple AWS environments for TDR:
* development (dev)
* test (test)
* production (prod)

### Terraform Workspaces vs "Stateful" Repository Structure

#### Terraform Workspaces

Advantages:
* Reduce repetition of code
* Sets up Terraform state in S3 under specific location without the need to manually specify S3 keys

Disadvantages:
* Unable to make use of the version management of modules through GitHub

#### "Stateful" Repository Structure

Advantages:
* Allow version management of modules through GitHub

Disadvantages:
* Repetition of code within each AWS environment setup
* Need to manually specify, and mantain S3 keys to store state

## Terraform State

* *Question: how to set up the Terraform backend (bootstrapping vs manual set up)?*

Terraform needs to keep track of the resources it creates to allow it to know which:
* real-life resource(s) are being changed when a resource is altered in a template;
* resource(s) to destroy when the a terraform destroy command is run.

By default, the terraform state is stored in a local folder `.terraform`. However, storing the state locally will mean it is inaccessible to other administrators.

To overcome this the current Terraform state is stored in an s3 bucket with a DynamoDB table to record the lock status. Using a DynamoDB table ensures that the state files are locked, whilst updating is being done.

### Terraform Backends - Persisting “State”

To preserve the Terraform state an s3 bucket needs to be created to store the /terraform.tfstate file that is generated by Terraform when applying the scripts. For example:

 ```
 terraform {
    backend "s3" {
    bucket         = "tdr-prototype-terraform-state"
    key            = "prototype-terraform/stateful/dev/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-statelock-tdr-prototype"
    #profile        = "terraform"
  }
}
```

* **bucket**: the s3 bucket name where the Terraform state will be stored
* **key**: path to the Terraform state file inside the bucket.

To record the lock status a DynamoDB table is needed.

* **dynamodb_table**: name of the DynamoDB table where the lock will be stored

The DynamoDB table should have “LockID” set as its “Primary Key”. The primary key needs to be  set when the DynamoDB table is created.

Both the s3 bucket(s) and DynamoDB table(s) need to be created before the Terraform scripts can be run.

### Useful Resources
* https://www.terraform.io/docs/backends/index.html
* Terraform workspaces: https://www.terraform.io/docs/state/workspaces.html
* Bootstrapping the backend: https://www.monterail.com/blog/chicken-or-egg-terraforms-remote-backend

##Modules

Modules are containers for multiple resources that are used together.

### Version modules in "Stateful" Repository Structure

For each new module that is needed a new GitHub repository should be created. This allows for clear versioning of the infrastucture, which in turns makes it easier to deploy new versions to lower environments for validation, before promotion to higher environments

Within the module the relevant GitHub version can then be referenced as the sources. For example:

```
module "cognito_admin" {
source = "git@github.com:nationalarchives/terraform-modules.git//cognito?ref=prod"
  ...
}
```
Here the module version for production (prod) is is referenced through the source attribute. In the development environment the module version for development would be referenced.

Useful Resources:
* https://www.oreilly.com/library/view/terraform-up-and/9781491977071/ch04.html
* https://www.terraform.io/docs/modules/index.html

## "Stateful" GitHub Repositories Structure

For an example structure for Terraform architecture see the following GitHub repositories used by Digital Services:
* Stateful repository: https://github.com/nationalarchives/Terraform-Stateful
* Modules repository: https://github.com/nationalarchives/terraform-modules

### Stateful Repository

Url: https://github.com/nationalarchives/tdr-prototype-terraform-stateful

This repository should contain the configuration for setting up the infrastructure using modules contained in the modules repository.

### Modules Repository

Url: https://github.com/nationalarchives/tdr-prototype-terraform-modules

This repository should contain the reusable modules, across environments that are used to provision the resources which are referenced by the stateful Terraform repository.

Will have branches to mirror the different environments required. For example:
* dev;
* testing;
* live.

Each individual module will have a separate folder within the repository.

## Cloning GitHub Modules

Where the module source is a GitHub repository, Terraform will clone the specified repository. To enable cloning GitHub credentials are needed.

## Coding Guidelines

### Tagging of Resources

Resources that are provisioned MUST BE tagged. This allows other users and systems adminstrators to understand who owns the resources.

See here for standards for tagging: https://github.com/nationalarchives/tna-aws-tagging-naming

For tagging of resources in TDR the following convention should be followed:

```
tdr-{serviceCode}-{applicationTypeCode}-{environmentCode}-{resource}-{role}
```

Service Codes:

[TODO]

Application Type Codes:

[TODO]

Environment Codes:
* dev
* test
* live

### Terraform Style Conventions

See the following for style conventions: https://www.terraform.io/docs/configuration/style.html

### Module Structure

The recommended structure for a module is:

- /module1
-- /main.tf
-- /outputs.tf
-- /variables.tf

#### /main.tf

Primary entry point for the module, and may be where all the resources for the module are created. Can be empty

#### /outputs.tf

This file will contain the declarations for any module values that needed to be exposed to any other modules within the infrastructure.

#### /variables.tf

Contains the variable declarations for the module.

## Testing Frameworks

* *Question: Is testing of the Terraform framework necessary?*

Two frameworks
* Terratest: GO open source library (under the Apache 2.0 license) - https://github.com/gruntwork-io/terratest#testing-best-practices
* Kitchen-Terraform:  open source set of Test Kitchen plugins for testing Terraform configuration -  https://newcontext-oss.github.io/kitchen-terraform/

## Further Resources

### Terraform

* Basic Terraform tutorial: https://learn.hashicorp.com/terraform/#getting-started
* Guide to setting up AWS resources:  https://www.terraform.io/docs/providers/aws/

### Using Terraform Workspaces to Manage Multiple Environments

* https://medium.com/capital-one-tech/deploying-multiple-environments-with-terraform-kubernetes-7b7f389e622
* https://dzone.com/articles/manage-multiple-environments-with-terraform-worksp

### Testing Terraform

* https://www.contino.io/insights/top-3-terraform-testing-strategies-for-ultra-reliable-infrastructure-as-code
* https://www.terraform.io/docs/extend/testing/unit-testing.html (Unit testing)

#### Kitchen Framework

* https://newcontext-oss.github.io/kitchen-terraform/getting_started.html
* https://www.darkraiden.com/blog/test-terraform-with-kitchen-and-awspec/

#### Terratest Framework

* https://winderresearch.com/how-to-test-terraform-infrastructure-code/
* https://github.com/gruntwork-io/terratest/tree/master/examples/terraform-aws-ecs-example
* https://github.com/gruntwork-io/terratest/blob/master/test/terraform_aws_ecs_example_test.go
* https://brightfame.co/blog/testing-your-terraform-project-with-terratest/
