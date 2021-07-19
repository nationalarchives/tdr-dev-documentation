# Clear Jenkins disk space
The jenkins EC2 instance periodically runs out of space because of unused docker images and volumes. Clearing these out is currently a manual task.

## Diagnosing the problem
When the instance runs out of space, any command that needs to write to disk, e.g.`docker build` or `sbt dist` will fail. There isn't usually a clear message indicating that it is a full disk that is causing the problem in the job logs themselves but if a job you were expecting to pass fails on a step which needs a lot of disk space, it may be that.

If you suspect this is the problem, you can go to the [manage jenkins](https://jenkins.tdr-management.nationalarchives.gov.uk/manage) page and it will show a message `Your Jenkins data directory is almost full`

## Connect to the Jenkins instance
Use the following command to connect the instance. This assumes that your SSO profile name is management, you have jq installed and you have permissions to run both aws commands.

`aws ssm start-session --profile management --target $(aws ec2 describe-instances --profile management --filters Name=instance-state-name,Values=running Name=tag:Name,Values=jenkins-task-definition-mgmt   | jq -r '.Reservations[].Instances[].InstanceId')`

## Set User with Docker Permissions
Run this command to set the correct user with docker permissions.

`sudo su ec2-user`

## Clear up docker volumes
Use this command to clean up any volumes that are not attached to a running container.

`docker volume ls -qf dangling=true | xargs -r docker volume rm`

## Clear up docker images
Use this command to clean up any docker images not being used by running containers.

`docker image prune -a`

## Check free disk space
Run this command to show the free space. You should have around 20% in use.

`df -h -t ext4`

## Re-create EC2 Instance

In some cases it may be impossible to connect to the Jenkins EC2 instance because it is too full.

In this circumstance the EC2 instance will need to be re-created.

**NOTE**: This option should **only** be used if connecting the Jenkins instance option has failed.

1. Go to the terraform directory: `$ cd terraform`
2. Check that there are no unexpected Terraform changes: `$ terraform plan`
3. If the Terraform appears as expected then run the following command:
  * For the integration Jenkins instance: `$ terraform taint module.jenkins_integration_ec2.aws_instance.instance`
  * For the production Jenkins instance: `$ terraform taint module.jenkins_ec2_prod.aws_instance.instance`
  * For more details on the `taint` command see here: https://www.terraform.io/docs/cli/commands/taint.html 
4. Run this command: `$ terraform apply`
  * The plan from the `apply` command should include any expected changes from step 2, and creation of new EC2 instance
5. If the plan appears correct proceed with the apply of the Terraform changes
6. Log into the AWS console and check that a new EC2 instance is created and the ECS service deploys. This may take some time.
