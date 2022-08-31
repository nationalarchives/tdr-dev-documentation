# Developer manual

A guide for developers working on TDR. This is a space to share _how_ to do
things like deploying code or debugging complex parts of the stack.

## Guides

### Accounts and permissions

* [Add a new AWS SSO group (internal manual)](https://github.com/nationalarchives/tdr-dev-documentation-internal/blob/main/manual/aws-sso-add-group.md)
* [GOV.UK notify access (internal manual)](https://github.com/nationalarchives/tdr-dev-documentation-internal/blob/main/manual/govuk-notify-access.md)
* [Leavers checklist (internal manual)](https://github.com/nationalarchives/tdr-dev-documentation-internal/blob/main/manual/leavers-checklist.md)
* [Update AWS SSO group permissions (internal manual)](https://github.com/nationalarchives/tdr-dev-documentation-internal/blob/main/manual/aws-sso-update-permissions.md)

### Admin Tasks

* [Deploy the service unavailable page](deploy-the-service-unavailable-page.md)
* [How to add a new series](add-new-series.md)

### Alerts

* [ECR scans](alerts/ecr-scans.md)
* [Missed Jenkins backups](alerts/missed-jenkins-backups.md)
* [Rotate AWS keys](alerts/rotate-aws-keys.md)
* [Rotate Client Secrets](alerts/client-secret-rotation.md)

### CI/CD

* [Clear Jenkins disk space](clear-jenkins-disk-space.md)
* [Jenkins style guide](jenkins-style-guide.md)
* [Reset Jenkins Builds](reset-jenkins-builds.md)
* [Update Jenkins](update-jenkins.md)

### Code repositories

* [Create a repo](create-repo.md)

### Database permissions
* [Fix permission denied errors for new tables](fix-database-permissions.md)

### Database restore
* [Restore either the Keycloak or Consignment API database](https://github.com/nationalarchives/tdr-scripts/blob/master/terraform/restore-database/README.md)

### Debugging

* [Creating or creating a bastion host for database access](debugging/applying-or-destroying-a-bastion-host.md)
* [Debug failing file checks](debugging/file-checks-do-not-run.md)
* [Find S3 upload folder](debugging/find-s3-upload-folder.md)
* [Security log queries (internal manual)](https://github.com/nationalarchives/tdr-dev-documentation-internal/blob/main/manual/security-log-queries.md)

### Development processes

* [Close a card](development-process/close-card.md)
* [Deploy code to production](development-process/production-deployemnt.md)
* [Plan a user story](development-process/plan-story.md)
* [Test accessibility of a feature](development-process/test-accessibility.md)

### Development setup

* [Access TDR accounts as a developer (internal manual)](https://github.com/nationalarchives/tdr-dev-documentation-internal/blob/main/manual/aws-sso-signin.md)
* [Install git secrets](development-setup/git-secrets.md)
* [New starters guide](development-setup/new-starters.md)
* [Set up signed commits](development-setup/signed-commits.md)

### Environment setup

* [Creating a new environment](create-new-environment.md)
* [Securing the Keycloak root user (internal manual)](https://github.com/nationalarchives/tdr-dev-documentation-internal/blob/main/manual/secure-keycloak-admin.md)
* [Setup TDR AWS Infrastructure](tdr-create-aws-instructure-setup.md)

### Keycloak

* [Retrieve Authorisation Token From Keycloak](keycloak-retrieve-token.md)
