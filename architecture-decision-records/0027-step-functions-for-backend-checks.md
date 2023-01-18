# 26. Step functions for backend checks

**Date:** 2023-01-18

## Context
Once the files in TDR are uploaded, we run antivirus, a server side checksum and a Droid file format check.

We also need to set various file and consignment statuses based on the results of the checks.

We also need to now the status of any redacted files in the consignment.

## Options considered
### Use the existing process
The existing process is driven by an SNS notification from S3 which triggers the backend checks lambdas. 
Communication between lambdas is handled by SQS queues.

#### Advantages
* It is event driven, so we don't have to manually trigger the process.
* It is cheaper, as there is a cost to the step functions.

#### Disadvantages
* It is controlled by a queue. If a large consignment is uploaded, followed by a small judgment consignment, the judgment consignment will need to wait for the large consignment to finish and this may take several hours.
* It is difficult to check statuses which apply across all files in a consignment, for example, all files need to be checked for redacted status.
* The API is called once for each file. This causes a lot of load on the database. 

### Use a step function
The step function will run once per consignment. 
It will be triggered by API Gateway and authenticated with the existing consignment export authoriser lambda.

#### Advantages
* It is run once per consignment which won't block smaller transfers with larger ones. 
* We can run a lambda once all the file checks are complete which means updating consignment statuses which apply to all files easier.
* It allows a lot of the status updates related to the backend checks to be decoupled from the API.
* It allows us to centralise the error handling, sending errors to the notifications service when there is any exception in the process.

#### Disadvantes
* It will be more expensive, as we have to pay for step function transitions as well as the lambda invocations we were already paying for.

## Decision
We have decided to move the backend checks to use step functions. The main reason is that this will prevent larger consignments blocking smaller ones. 
By moving a lot of the status logic out of the API and into the step function, we can make the API less complicated and easier to maintain.
As we are only updating the API once per consignmnent, we can run more of the checks in parallel which shoudl reduce the time taken for the checks on large numbers of files.
