# 16. Local Development Stack for GovUK Notify

**Date:** 2021-04-08

## Context

GovUK Notify is used as the email provider for Keycloak: [0012 Keycloak Email Provider](0012-keycloak-email-provider.md)

## Decision

No Full Local Development Stack for GovUK Notify.

GovUK Notify does not interact with any other TDR systems, therefore setting up a full local development stack is not necessary.

## Additional Notes

Until now, we have had the concept of a fully [local development environment](https://github.com/nationalarchives/tdr-transfer-frontend#full-stack-local-development)

So this is a break with what we've done before, which is why it's worth recording in a decision. 

We may revisit this decision if we see other advantages to having a local fake version of Notify for dev purposes, or if we ever make use of GovUK Notify's callbacks, which will mean that Notify does need to connect back to a TDR endpoint.

## Further Information

Full GovUK Notify documentation can be found here: https://www.notifications.service.gov.uk/
