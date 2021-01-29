# Clear Jenkins disk space
The jenkins EC2 instance periodically runs out of space because of unused docker images and volumes. Clearing these out is currently a manual task.

## Connect to the Jenkins instance
Use the following command to connect the instance. This assumes that your SSO profile name is management, you have jq installed and you have permissions to run both aws commands.

`aws ssm start-session --profile management --target $(aws ec2 describe-instances --profile management --filters Name=instance-state-name,Values=running Name=tag:Name,Values=jenkins-task-definition-mgmt   | jq -r '.Reservations[].Instances[].InstanceId')`

## Clear up docker volumes
Use this command to clean up any volumes that are not attached to a running container.

`docker volume ls -qf dangling=true | xargs -r docker volume rm`

## Clear up images
Use this command to clean up any docker images not being used by running containers.

`docker image prune -a`