# Terraform Testing

There is a question as to whether it is worthwhile introducing testing of the Terraform scripts.

Testing of Terraform is not something that has been adopted by the Digital Services team.

There appear to be several approaches to providing some form of testing, but most of the current technologies are not mature.

This blog post provides a useful overview of current practices: https://www.contino.io/insights/top-3-terraform-testing-strategies-for-ultra-reliable-infrastructure-as-code
* Using the inbuilt Terraform ```plan``` command
* Integration testing using an existing testing framework such as Kitchen-Terraform, Terratest
* Unit testing

There are some frameworks available. The main frameworks appear to be:
* Kitchen-Terraform
* Terratest

There are other tools available, but these are very new, or do not appear to have strong support:
* Rspec-Terraform: https://github.com/bsnape/rspec-terraform
* Terraform Acceptance Testing: https://github.com/hashicorp/terraform/blob/master/.github/CONTRIBUTING.md#writing-an-acceptance-test
* Goss: https://github.com/aelsabbahy/goss

## Terraform ``plan`` Command

This is inbuilt Terraform functionality that allows the user to see any changes, before Terraform applies these changes.

### Advantages
* Quick development time
* No additional setup required as built into Terraform
* Easy to learn

### Disadvantages
* Hard to spot mistakes
* Does not scale well

## Terratest

Terratest is an open source Go library provided by Gruntwork for writing automated tests for infrastructure code.

Relies on creating the AWS resources as part of the testing, and applying tests to those resources.

### Advantages
* Provides teardown of AWS resources as part of the tests
* Supports both unit tests and integration testing (https://docs.microsoft.com/en-us/azure/terraform/terratest-in-terraform-modules)
* Organized folder structure following standard Terraform module folder structure
* Helpers to check infrastructure
* Extensible

### Disadvantages
* Complex setup
* Relatively immature: 2016
* Limited documentation
* Forces the project to be installed on the GoPath/src path to so can run
* Will require separate AWS environment to run the tests
* Test output report hard to configure regarding verbosity

### Dependencies
* Golang

### Useful Resources
* Introductory Blog: https://blog.gruntwork.io/open-sourcing-terratest-a-swiss-army-knife-for-testing-infrastructure-code-5d883336fcd5
* Source Code: https://github.com/gruntwork-io/terratest
* https://blog.octo.com/en/test-your-infrastructure-code-with-terratest/

## Kitchen-Terraform

Kitchen-Terraform is an open soure set of plugins provided by New Context, for the Test Kitchen integration test framework for testing Terraform code.

Relies on creating the AWS resources as part of the testing, and applying tests to those resources.

### Advantages
* Makes use of established testing frameworks, Kitchen and Inspec

### Disadvantages
* Complex setup
* Learning Inspec testing structure
* Have to specify teardown of AWS resources generated for testing in seperate bash scripts
* Relatively immature: 2016
* Limmited documentation

### Dependencies
* Ruby

### Useful Resources
* https://www.newcontext.com/kitchen-terraform/
* https://newcontext-oss.github.io/kitchen-terraform/
* https://www.darkraiden.com/blog/test-terraform-with-kitchen-and-awspec/

## Recommendations

Terratest and Kitchen-Terraform to pick up issues that would not be directly obvious using existing AWS monitoring tools, such as tagging and variable names. They could provide a useful additional level of checking when developing. 

Both main options Kitchen-Terraform and Terratest are new, and not well integrated into Terraform.

The setup and learning requirements are high.

It is recommended to use the Terraform ```plan``` option until testing options for Terraform are more mature. This should be reviewed as the AWS infrastucture becomes more complex and the benefits in investing in testing maybe higher.


