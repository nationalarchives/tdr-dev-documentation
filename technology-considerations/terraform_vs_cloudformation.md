# Tool evaluation Terraform vs CloudFormation 

Date:2019-07-15

We have decided to build TDR on the AWS infrastructure.
The reliable way to automate creating, updating and deleting our cloud resources is to describe the target state of our infrastructure and use a tool to apply it to the current state.
CloudFormation and Terraform are the best known tools to implement Infrastructure as Code on AWS.

We have decided to start with Terraform because:
- we have some experience in the team with Terraform
- other teams in The National Archives are currently using Terraform
- it's cloud agnostic, so even if we don't transfer the resources to another cloud provider, we could still reuse the knowledge