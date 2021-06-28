# Developer manual

A guide for developers working on TDR. This is a space to share _how_ to do
things like deploying code or debugging complex parts of the stack.

## Guides

### Accounts and permissions

* [Add a new AWS SSO group (Sharepoint)](https://nationalarchivesuk.sharepoint.com/:w:/r/sites/DA_Proj/Transfer%20Digital%20Records/Documentation/Developer%20manual/Add%20an%20AWS%20SSO%20group.docx?d=w083a19f8e9704d209e93163a3a776992&csf=1&web=1&e=judnGD)
* [GOV.UK notify access (Sharepoint)](https://nationalarchivesuk.sharepoint.com/:w:/r/sites/DA_Proj/Transfer%20Digital%20Records/Documentation/Developer%20manual/GovUK%20Notify%20Access.docx?d=w65cef45462604245872143e1703f26f8&csf=1&web=1&e=NIEumr)
* [Leavers checklist (Sharepoint)](https://nationalarchivesuk.sharepoint.com/:w:/r/sites/DA_Proj/Transfer%20Digital%20Records/Documentation/Developer%20manual/GovUK%20Notify%20Access.docx?d=w65cef45462604245872143e1703f26f8&csf=1&web=1&e=NIEumr)
* [Update AWS SSO group permissions (Sharepoint)](https://nationalarchivesuk.sharepoint.com/:w:/r/sites/DA_Proj/Transfer%20Digital%20Records/Documentation/Developer%20manual/Security%20log%20queries.docx?d=w757b4033c718479eb0b1050a8328eb46&csf=1&web=1&e=fh1pOE)

### Alerts

* [ECR scans](alerts/ecr-scans.md)
* [Missed Jenkins backups](alerts/missed-jenkins-backups.md)
* [Rotate AWS keys](alerts/rotate-aws-keys.md)

### CI/CD

* [Clear Jenkins disk space](clear-jenkins-disk-space.md)
* [Jenkins style guide](jenkins-style-guide.md)
* [Reset Jenkins Builds](reset-jenkins-builds.md)
* [Update Jenkins](update-jenkins.md)

### Code repositories

* [Create a repo](create-repo.md)

### Database restore
* [Restore either the Keycloak or Consignment API database](https://github.com/nationalarchives/tdr-scripts/blob/master/terraform/restore-database/README.md)

### Debugging

* [Debug failing file checks](debugging/file-checks-do-not-run.md)
* [Find S3 upload folder](debugging/find-s3-upload-folder.md)
* [Security log queries (Sharepoint)](https://nationalarchivesuk.sharepoint.com/:w:/r/sites/DA_Proj/Transfer%20Digital%20Records/Documentation/Developer%20manual/Security%20log%20queries.docx?d=w757b4033c718479eb0b1050a8328eb46&csf=1&web=1&e=fh1pOE)

### Development processes

* [Close a card](development-process/close-card.md)
* [Plan a user story](development-process/plan-story.md)

### Development setup

* [Access TDR accounts as a developer (Sharepoint)](https://nationalarchivesuk.sharepoint.com/:w:/r/sites/DA_Proj/Transfer%20Digital%20Records/Documentation/Developer%20manual/Access%20TDR%20AWS%20accounts%20as%20a%20developer.docx?d=wcaf74cb6342f4235983405fb528d3eb1&csf=1&web=1&e=uGUZ6A)
* [Install git secrets](development-setup/git-secrets.md)
* [New starters guide](development-setup/new-starters.md)

### Environment setup

* [Creating a new environment](create-new-environment.md)
* [Securing the Keycloak root user (Sharepoint)](https://nationalarchivesuk.sharepoint.com/:w:/r/sites/DA_Proj/Transfer%20Digital%20Records/Documentation/Developer%20manual/GovUK%20Notify%20Access.docx?d=w65cef45462604245872143e1703f26f8&csf=1&web=1&e=NIEumr)
* [Setup TDR AWS Infrastructure](tdr-create-aws-instructure-setup.md)

### Keycloak

* [Retrieve Authorisation Token From Keycloak](keycloak-retrieve-token.md)
