# TDR Network Diagram

![diagram]

[diagram]: TDR.svg "TDR Network Diagram"

This can be broken down by the function of each section

## MVC App
There is an ECS cluster containing one service which runs a single Fargate container. The container runs a docker image with the Play app installed. The app uses Cognito for authentication.

The cluster is in a private subnet. Inbound traffic comes from the application load balancer through a network interface and outbound traffic goes out over the nat gateway.

Route 53 is setup to send traffic to the load balancer. 

## Graphql Server
There is an ECS cluster containing one service which runs a single Fargate container. The container runs a docker image with the Sangria app installed.

Route 53 is setup to send traffic to one of two API Gateway endpoints. One if these uses Cognito for authentication and the other uses IAM. The request is sent through a VPC link to the network load balancer
The load balancer then sends traffic into the private subnet. Outbound traffic goes out over the nat gateway.

 
## Database
This is an Aurora database which sits in the private subnet and is access through the network interface. Currently only the graphql service talks directly to the database. 

## Backend checks
When a file is uploaded to the S3 bucket, this triggers an event in cloudtrail. 

There is a cloudwatch rule setup to listen for this event which in turn triggers the step function.

The step function runs three Fargate tasks in parallel, one for each of the backend checks. 

On success or failure, the step function sends the output to an SNS topic. This triggers a lambda which updates the database via the graphql server with the result from the container. 




