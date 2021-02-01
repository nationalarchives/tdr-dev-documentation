# Clear Jenkins disk space
The jenkins EC2 instance periodically runs out of space because of unused docker images and volumes. Clearing these out is currently a manual task.

## Diagnosing the problem
When the instance runs out of space, any command that needs to write to disk, e.g.`docker build` or `sbt dist` will fail. There isn't usually a clear message indicating that it is a full disk that is causing the problem in the job logs themselves but if a job you were expecting to pass fails on a step which needs a lot of disk space, it may be that.

If you suspect this is the problem, you can go to the [manage jenkins](https://jenkins.tdr-management.nationalarchives.gov.uk/manage) page and it will show a message `Your Jenkins data directory is almost full`

## Connect to the Jenkins instance
Use the following command to connect the instance. This assumes that your SSO profile name is management, you have jq installed and you have permissions to run both aws commands.

`aws ssm start-session --profile management --target $(aws ec2 describe-instances --profile management --filters Name=instance-state-name,Values=running Name=tag:Name,Values=jenkins-task-definition-mgmt   | jq -r '.Reservations[].Instances[].InstanceId')`

## Clear up docker volumes
Use this command to clean up any volumes that are not attached to a running container.

`docker volume ls -qf dangling=true | xargs -r docker volume rm`

## Clear up images
Use this command to clean up any docker images not being used by running containers.

`docker image prune -a`

## Check free disk space
Run this command to show the free space. You should have around 20% in use.

`df -h -t ext4`