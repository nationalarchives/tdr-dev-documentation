# Terraform Testing

There is a question as to whether it is worthwhile introducing testing of the Terraform scripts.

Testing of Terraform is not something that has been adopted by the Digital Services team.

There appear to be several approaches to providing some form of testing, but most of the current technologies are not mature.

This blog post provides a useful overview of current practices: https://www.contino.io/insights/top-3-terraform-testing-strategies-for-ultra-reliable-infrastructure-as-code
* Using the inbuilt Terraform ```plan``` command
* Integration testing using an existing testing framework such as Kitchen-Terraform, Terratest
* Unit testing

## Terraform ``plan`` Command

This is inbuilt Terraform functionality that allows the user to see any changes, before Terraform applies these changes.

Advantages include:
* Quick development time
* No additional setup required as built into Terraform
* Easy to learn

Disadvantages include:
* Hard to spot mistakes
* Does not scale well

## Terratest

Terratest is an opensource Go library provided by Gruntwork for writing automated tests for infrastructure code.

### Useful Resources
* Introductory Blog: https://blog.gruntwork.io/open-sourcing-terratest-a-swiss-army-knife-for-testing-infrastructure-code-5d883336fcd5
* Source Code: https://github.com/gruntwork-io/terratest

## Kitchen-Terraform

Kitchen-Terraform is an open soure set of plugins for the Test Kitchen integration test framework for testing Terraform code.

### Useful Resources
* https://newcontext-oss.github.io/kitchen-terraform/
