# Applying or destroying a Bastion host

Using a bastion to connect to the database should be a last resort. For business as usual tasks, we should have API endpoints which provide the required data.
## Applying a Bastion host

To bring up a Bastion host you must:

* Go to the "TDR scripts" repo on GitHub and select the ["Actions" tab](https://github.com/nationalarchives/tdr-scripts/actions/workflows/bastion_deploy.yml)
* Click the "Run workflow" button
* For "The stage to deploy the bastion to" - Enter the environment you wish to access e.g. `intg`
* For "Whether to apply or destroy the bastion" - keep as `apply`
* Check the box to "Allow the bastion to connect to the database"
* Click the "Run workflow" button
* In the list of "Workflow runs", you should see one with an orange clock called "Deploy bastion" that was "Manually run by {you}" with the status Waiting (This is because it needs to be approved).

* In order to approve the run, click on "Deploy bastion"
* Select "Review deployments"
* Check the box with the environment next to it e.g. intg
* Click the "Approve and deploy" button

## Destroying a Bastion host

To bring down a Bastion host you must:

* Go to the "TDR scripts" repo on GitHub and select the ["Actions" tab](https://github.com/nationalarchives/tdr-scripts/actions/workflows/bastion_deploy.yml)
* Click the "Run workflow" button
* For "The stage to deploy the bastion to" - Enter the environment of the Bastion you wish to destroy e.g. `intg`
* For "Whether to apply or destroy the bastion" - from the dropdown menu, select `destroy`
* Check the box to "Allow the bastion to connect to the database"
* Click the "Run workflow" button
* In the list of "Workflow runs", you should see one with an orange clock called "Deploy bastion" that was "Manually run by {you}" with the status Waiting (This is because it needs to be approved).

* In order to approve the run, click on "Deploy bastion"
* Select "Review deployments"
* Check the box with the environment next to it e.g. intg
* Click the "Approve and deploy" button
