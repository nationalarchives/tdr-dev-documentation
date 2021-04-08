# 14. GovUK Notify Service Configuration

**Date:** 2021-04-08

## Context

GovUK Notify is used as the email provider for Keycloak: [0012 Keycloak Email Provider](0012-keycloak-email-provider.md)

There are multiple ways that GovUK Notify can be configured for a multi-environment architecture such as TDR uses.

TDR has three environments:
* integration
* staging 
* production

GovUK Notify does not have a specific concept of different environments.

## Decision: Separate GovUK Notify Services for each TDR Environment

It was decided to configure GovUK Notify so that each TDR environment had it's own separate GovUK Notify Service.

This was because this approach:
* Provides the ability to control user access to GovUK Notify according to the service setup. 
* Isolates the GovUK notify setup for each environment allowing for safe deployments of changes to each TDR environment.

The downside of this approach is that it means the GovUK Notify email templates have to be maintained and kept in sync for each of the different GovUK Notify services set up. Though it is likely that changes to the email templates will be minimal after the initial setup.

### Other Options Considered

#### Single GovUK Notify Service with Multiple API Keys

This was rejected because it would lack the control over user access to the different TDR environments emails and configuration. 

For example a GovUK Notify service member would have the same level of access across all TDR environments.

## Decision: GovUK Notify Staging Service made Live

The "staging" GovUK Notify service is to be live to allow for user testing on this environment. Also it will mirror the TDR production environment as closely as possible.

## Decision: No Fully Local Development Stack for GovUK Notify

GovUK Notify does not interact with any other TDR systems, therefore setting up a full local development stack is not necessary.

## Decision: Full Keycloak Generated Message Passed into GovUK Notify Template

It was decided to pass the entire Keycloak message into the GovUK Notify template via the `keycloakMessage` personalisation parameter, rather than having a mix of text and parameters in the Keycloak template.

This was because the Keycloak message is passed in as a complete constructed string. It would be very difficult to extract particular portions of this string, for example a link for use within the GovUK Notify template.

## Further Information

Full GovUK Notify documentation can be found here: https://www.notifications.service.gov.uk/
