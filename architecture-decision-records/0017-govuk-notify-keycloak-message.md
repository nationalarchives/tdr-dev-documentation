# 17. Passing Keycloak Message Parameters to GovUK Notify

**Date:** 2021-04-08
  
## Context
  
GovUK Notify is used as the email provider for Keycloak: [0012 Keycloak Email Provider](0012-keycloak-email-provider.md)

## Decision

It was decided to pass the entire Keycloak message into the GovUK Notify template via the `keycloakMessage` personalisation parameter, rather than having a mix of text and parameters in the Keycloak template.

This is because the Keycloak message is passed in as a complete constructed string. It would be very difficult to extract particular portions of this string, for example a link for use within the GovUK Notify template.

This approach does mean it is harder for non-developers to make changes to the email messages. The decision may be revisited in the future if this proves to be causing issues.

## Further Information

Full GovUK Notify documentation can be found here: https://www.notifications.service.gov.uk/
