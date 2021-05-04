# 15. GovUK Notify Staging Service made Live

**Date:** 2021-04-08

This decision has been superseded by decision: [0018 GovUK Notify Staging Configuration](0018-govuk-notify-staging-configuration.md)

## Context

GovUK Notify is used as the email provider for Keycloak: [0012 Keycloak Email Provider](0012-keycloak-email-provider.md)

It was decided to use a separate GovUK Notify service for each TDR environment as GovUK Notify does not have the concept of environments: [0014 GovUK Notify Multi-environment Configuration](0014-govuk-notify-multi-environment-configuration.md)

GovUK services have a "trial mode", and a "live mode". 

The trial mode has limits placed on who can receive emails, and the number of emails that can be sent.

## Decision

The "staging" GovUK Notify service is to be live to allow for user testing on this environment. 

Also, it will mirror the TDR production environment as closely as possible.

## Further Information

Full GovUK Notify documentation can be found here: https://www.notifications.service.gov.uk/
