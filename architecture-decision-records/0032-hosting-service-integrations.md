# 32. Hosting Service Integrations

**Date:** 2024-06-07

## Context

TDR needs to support transfers from additional sources other than network drives, for example SharePoint, Google Drive, hard drives etc.

This will require the exposure of endpoints so other services can integrate with TDR to allow the transfers from such sources, along with additional processing of metadata and records.

The additional processing and endpoints will need to be hosted by the TDR infrastructure.

Such transfers are likely to involve much larger volume transfers in terms of number of records and overall size. In addition bespoke processing of the data is likely to be needed.

## Decision

Decision to host the necessary code for supporting transfer from additional sources on a new AWS ECS Task within existing TDR's VPC.

This provides the following advantages:
* Service integrations always available
* Flexibility to extend with future requirements
* Potential to handle higher volume transfers
* Less burden on existing TDR infrastructure used to support network transfers
* Take advantage of TDR's existing access controls to the VPC (for example WAF rules)

### Disadvantages to hosting on new ECS Task

* Higher maintenance burden as less code re-use - potential mitigation with abstracting existing TDR frontend code to re-use
* Potential higher AWS cost running additional ECS task - potential mitigation with closing down service over weekends etc

## Other Options Considered

### Hosting on existing TDR Frontend ECS Task

#### Advantages

* Re-use existing code, such as authorisation and authentication, connections with other TDR services
* Lower maintenance burden
* Lower potential AWS cost burden

#### Disadvantages

* Code was not designed for supporting endpoints externally exposed
* Capacity issues with larger transfers, ECS task already at capacity at peak usage supporting the TDR frontend

### Hosting on AWS API Gateway and Lambda

#### Advantages

* Serverless architecture with potential cost savings
* Use AWS API Gateway features

#### Disadvantages

* Large amount of additional AWS infrastructure to create and maintain
* Lambda "cold start" causing lag on transfers
* Securing endpoints whilst allowing external access will be difficult
