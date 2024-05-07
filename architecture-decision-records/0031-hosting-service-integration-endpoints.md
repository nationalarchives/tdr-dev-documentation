# 31. Hosting Service Integration Endpoints

**Date:** 2024-MM-DD

## Context

TDR needs to support transfers from additional sources other than network drives, for example Sharepoint, Google Drive, hard drives etc.

This requires the exposure of endpoints so other services can integrate with TDR to allow the transfers from such sources.

These endpoints will need to be hosted by the TDR infrastructure.

Such transfers are likely to involve much larger volume transfers in terms of number of records and overall size.

## Decision

Decision to host the endpoints on a new AWS ECS Task within TDR's VPC.

This provides the following advantages:
* Service integrations always available
* Flexibility to extend with future requirements
* Potential to handle high volume transfers
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
* AWS API Gateway features

#### Disadvantages

* Large amount of additional AWS infrastructure to create and maintain
* Lambda "cold start" causing lag on transfers
* Securing endpoints whilst allowing external access will be difficult
