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

## Jenkins IAM key

If the resource name in the alert message is "jenkins-ecs", the Jenkins access
key needs to be rotated.

Jenkins ECS nodes use IAM roles to access resources (e.g. to run deployments),
and so do not need IAM access keys. We do need one key, however, to give the
[Jenkins ECS plugin] permission to start Jenkins ECS nodes.

See the `credentials` and `ecs` sections of [jenkins.yml] to see where this key
is referenced.

To rotate this key:

- Sign into the AWS management account
- Go to the IAM service
- Find the "jenkins-ecs" user
- Go to the Security Credentials tab
- Create a new access key
- Go to Systems Manager, then Parameter Store
- Update these values:
  - Set `/mgmt/access_key` to the new access key ID
  - Set `/mgmt/secret_key` to the new secret key
- Restart the Jenkins ECS task
- Check that the [credentials store] and [Jenkins cloud configuration] show the
  access key ID of the new key
- To test the configuration, run a Jenkins task that uses an ECS node, such as
  the frontend tests
- Go back to IAM and make the old key inactive
- Once you're confident that Jenkins builds are unaffected, delete the old key.
  The Cloud Custodian alerts will continue until the key has been deleted

[Jenkins ECS plugin]: https://github.com/jenkinsci/amazon-ecs-plugin
[jenkins.yml]: https://github.com/nationalarchives/tdr-jenkins/blob/master/docker/jenkins.yml
[credentials store]: https://jenkins.tdr-management.nationalarchives.gov.uk/credentials/
[Jenkins cloud configuration]: https://jenkins.tdr-management.nationalarchives.gov.uk/configureClouds/
