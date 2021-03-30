# Applying or destroying a Bastion host

Using a bastion to connect to the database should be a last resort. For business as usual tasks, we should have API endpoints which provide the required data. 
## Applying a Bastion host

To bring up a Bastion host you must:

* Go to the Bastion deploy job on [Jenkins](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Bastion%20Deploy/build)
* From the "Stage" dropdown, choose the environment that you want to apply the bastion host to
* From the "Command" dropdown, select "Apply"
* **Optionally**, if you want to create an ssh tunnel you can add an ssh key. [Instructions to setup the tunnel](./access-an-environment-db.md#5-setting-up-an-ssh-tunnel)
* Click the "Build" button

## Destroying a Bastion host

To bring down a Bastion host you must:

* Go to the Bastion deploy job on [Jenkins](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Bastion%20Deploy/build)
* From the "Stage" dropdown, choose the environment that you want to apply the bastion host to
* From the "Command" dropdown, select "Destroy"
* Click the "Build" button