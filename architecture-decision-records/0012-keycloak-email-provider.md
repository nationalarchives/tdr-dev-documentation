# 12. Keycloak Email Provider

**Date:** 2020-11-16

## Context

Set up Keycloak email provider to be able to send transferring bodies emails for updating passwords, and other Keycloak based user actions.

## Decision

Decided to go with GovUK Notify as the email provider because:
* Re-using existing UK Government service.
* Ability to leverage GovUK branding to create specific TDR branding for emails.
* Free service.
* 24 hour support.
* NCSC compliant service.
* Relatively easy to integrate into Keycloak.
* Supports SMS. Might make things easier if there is a need to implement MFA via text messages.

### Disadvantages to GovUK Notify

* Logging not integrated with TDR application logging on AWS.
* Another account to manage for TDR.

### Documentation

See here for further information on GovUK Notify: https://www.notifications.service.gov.uk

## Other Options Considered

### AWS Simple Email Service (SES)

#### Advantages

* Integration with other TDR logging events on AWS

#### Disadvantages

* Does not support SMS. This may become relevant if need to support MFA via SMS text messages for TDR.
* Stripping of styling from email HTML, going to make adding branding to emails difficult.
* Clunky support for templates, JSON + AWS CLI for sending.

#### Documentation

See here for further information on AWS SES: https://aws.amazon.com/ses/

### SendGrid

Rejected due to cost.

#### Documentation

See here for further information on SendGrid: https://sendgrid.com/
