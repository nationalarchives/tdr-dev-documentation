# TDR Network Diagram

![diagram]

[diagram]: TDR.svg "TDR Network Diagram"

This can be broken down by the function of each section

## MVC App
There is an ECS cluster containing one service which runs a single Fargate container. The container runs a docker image with the Play app installed. The app uses the Silhouette library for authentication with the user data stored in the database and accessed via the API.

The cluster is in a private subnet. Inbound traffic comes from the application load balancer through a network interface and outbound traffic goes out over the nat gateway.

Route 53 is setup to send traffic to the load balancer. 

## Graphql Server
There is an ECS cluster containing one service which runs a single Fargate container. The container runs a docker image with the Sangria app installed.

Route 53 is setup to send traffic to the API Gateway endpoint. The endpoint uses IAM for authentication. The request is sent through a VPC link to the network load balancer
The load balancer then sends traffic into the private subnet. Outbound traffic goes out over the nat gateway.

 
## Database
This is an Aurora database which sits in the private subnet and is access through the network interface. The plan is that the Graphql server will be the only thing that talks to the database. Anything that needs to read or update data will go through the API. 

## Backend checks
When a file is uploaded to the S3 bucket, this triggers an event in cloudtrail. 

There is a cloudwatch rule setup to listen for this event which in turn triggers the step function.

The step function runs three Fargate tasks in parallel, one for each of the backend checks. 

On success or failure, the step function sends the output to an SNS topic. This triggers a lambda which updates the database via the graphql server with the result from the container.


## Export task
There is an export task which runs a combination of scala and bash scripts to generate a [BagIt](http://www.dcc.ac.uk/resources/external/bagit-library) bag which is uploaded to an S3 bucket. This is currently triggered directly from within the API but this will change. 




