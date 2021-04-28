# 18. GovUK Notify Staging Service made Live

**Date:** 2021-04-22

This decision supersedes decision: [0015 GovUK Notify Staging Configuration](0015-govuuk-notify-staging-configuration.md)

## Context

It was decided to set the GovUK Notify Staging service to go live: [0015 GovUK Notify Staging Configuration](0015-govuuk-notify-staging-configuration.md)

## Decision

The GovUK Notify team recommended that usually they do not go live with non-production services.

It was decided to not go live with the GovUK Notify Staging services following this advice from the GovUK Notify team.

It is still possible to send emails to users participating with UAT via adding their email addresses to the service's guest list.

The Staging service is sufficiently consistent with the Production service if it were to remain in "trial mode".

For full details of the "trial mode" for GovUK Notify services see here: https://www.notifications.service.gov.uk/using-notify/trial-mode
