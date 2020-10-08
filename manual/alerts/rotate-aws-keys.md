# Rotate AWS access keys

This is what to do when we get a Cloud Custodian alert about an old access key.
The Slack alert looks like this:

```
Custodian

Resources
some-iam-account-name

Account
some-aws-account

Region
some-region

Violation Description
Access keys over 80 days old

Action Description
Rotate AWS access keys now - keys over 90 days old will be deleted
```

## Developer IAM accounts

If the IAM account belongs to a developer, then consider whether the key or the
IAM account can be deleted. We use [AWS SSO] for regular access to AWS, so there
should be no need for a developer to have a permanent IAM access key unless
there is a problem with SSO.

[AWS SSO]: https://aws.amazon.com/single-sign-on/

