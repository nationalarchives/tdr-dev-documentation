# Applying or destroying a Bastion host

Using a bastion to connect to the database should be a last resort. For business as usual tasks, we should have API endpoints which provide the required data. 
## Applying a Bastion host

To bring up a Bastion host you must:

* Go to the Bastion deploy job on [Jenkins](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Bastion%20Deploy/build)
* From the "Stage" dropdown, choose the environment that you want to apply the bastion host to
* From the "Command" dropdown, select "Apply"
* Select the checkbox of what you'd like to connect to (more information about what wach one does can be found [here](https://github.com/nationalarchives/tdr-scripts#bastion-host-creation-script):
  * CONNECT_TO_BACKEND_CHECKS_EFS
  * CONNECT_TO_DATABASE
  * CONNECT_TO_EXPORT_EFS
* **Optionally**, if you want to create an ssh tunnel you can add an ssh public key in the jobs PUBLIC_KEY paramater. [Instructions to create a key pair](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
* Click the "Build" button

## Destroying a Bastion host

To bring down a Bastion host you must:

* Go to the Bastion deploy job on [Jenkins](https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Bastion%20Deploy/build)
* From the "Stage" dropdown, choose the environment that you want to apply the bastion host to
* From the "Command" dropdown, select "Destroy"
* Click the "Build" button
