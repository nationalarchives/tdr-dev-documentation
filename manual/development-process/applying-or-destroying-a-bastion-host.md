# Applying or destroying a Bastion host

## Applying a Bastion host

To bring up a Bastion host you must:

* Go to the Bastion deploy job on [Jenkins](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Bastion%20Deploy/build)
* From the "Stage" dropdown, choose the environment that you want to apply the bastion host to
* From the "Command" dropdown, select "Apply"
* **Optionally**, if you want to create an ssh tunnel you can add an ssh key.
* Click the "Build" button

## Destroying a Bastion host

To bring down a Bastion host you must:

* Go to the Bastion deploy job on [Jenkins](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Bastion%20Deploy/build)
* From the "Stage" dropdown, choose the environment that you want to apply the bastion host to
* From the "Command" dropdown, select "Destroy"
* **Optionally**, if you want to create an ssh tunnel you can add an ssh key.
* Click the "Build" button
