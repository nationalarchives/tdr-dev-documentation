# Update Jenkins

Jenkins needs to be kept up to date in several ways: we need to update the EC2
instance it runs on, the Jenkins application itself, and all of its plugins.

All the code needed to update Jenkins is in the [tdr-jenkins] repo.

## Preparation

**Before running any updates**:

* Run the [TDR Jenkins Backup]
* Warn other developers that Jenkins will be unavailable for a few minutes

It is a good idea to run the [TDR Jenkins Backup] job before deploying Jenkins.
Deploying the Jenkins Docker container wipes the job history, which is then
restored from backup before Jenkins starts up. If you don't run the backup job
before deploying, the restored backup will be from the previous nightly job,
which might mean that you lose some newly created jobs or recent job history.

If you do lose recent job history, and it causes Jenkins build numbers to go out
of sync with the the release version tags in git, you can [reset the Jenkins
build numbers][reset-builds] for the affected jobs.

## Update the EC2 instance

Jenkins is deployed as a Docker container running in ECS. We use the latest
[ECS-optimised Application Machine Image (AMI)][ecs-ami] available in AWS.

To update to the latest image, set up the tdr-jenkins Terraform project and run
`terraform apply`. This should automatically pick up the latest AMI.

Terraform needs to destroy and rebuild an EC2 image, so Terraform will take a
few minutes to exit. You can monitor progress in the AWS console by checking the
state of the EC2 image. The old image will be deleted by AWS after a few hours.

You can then monitor deployment by checking the events in the
[jenkins-service-mgmt] service in the AWS Console, and the
[/ecs/tdr-jenkins-mgmt][jenkins-logs] CloudWatch log group.

## Update the Jenkins application version

The TDR Jenkins Docker build is based on the latest version of the official
Jenkins Docker image, so building the TDR Docker image will pick up the latest
stable Jenkins release.

Follow the instructions for building and deploying the Docker image in the
[tdr-jenkins] repo.

## Update the Jenkins plugins

The Jenkins [plugin manager] page shows what plugins need to be updated.

### Option 1: Update plugin list

This is the simplest way to update plugins if there are only a small number of
updates to install.

Edit [plugins.txt] and update the version to the latest available version. Then
build and deploy the Jenkins Docker image as above.

### Option 2: Manually update plugins

This is the simplest way to update a large number of plugins at once.

- On the Jenkins plugin manager update page, click "Select: Compatible" at the
  bottom of the page. (Or click "All" if you have fixed any issues with
  incompatible plugins or want to test the upgrade anyway.)
- Click "Download now and install after restart"
- As the plugins are being installed, check the "restart" checkbox at the bottom
  of the list
- Wait for Jenkins to restart, monitoring the [jenkins-logs] in CloudWatch for
  any errors
- Export the latest plugin versions by running this in the [script console]:

  ```
  def pluginList = new ArrayList(Jenkins.instance.pluginManager.plugins)
  pluginList.sort { it.getShortName() }.each{
    plugin ->
      println ("${plugin.getShortName()}:${plugin.getVersion()}")
  }
  ```

- Copy the output to the [plugins.txt] file
- Build and push the Docker image
- Redeploy the Docker image, as a final test of the plugins

If the manual upgrade fails, redeploy the Docker image by stopping the ECS task.
This will reset Jenkins, including the plugin versions.

## Testing the updates

Any issues with the updates might only appear when you run a Jenkins job, so
test the update by running some branch builds and integration deployments.

[tdr-jenkins]: https://github.com/nationalarchives/tdr-jenkins/
[TDR Jenkins Backup]: https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Jenkins%20Backup/
[reset-builds]: reset-jenkins-builds.md
[ecs-ami]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
[jenkins-service-mgmt]: https://eu-west-2.console.aws.amazon.com/ecs/home?region=eu-west-2#/clusters/jenkins-mgmt/services/jenkins-service-mgmt/events
[plugins.txt]: https://github.com/nationalarchives/tdr-jenkins/blob/master/docker/plugins.txt
[jenkins-logs]: https://eu-west-2.console.aws.amazon.com/cloudwatch/home?region=eu-west-2#logStream:group=/ecs/tdr-jenkins-mgmt
[plugin manager]: https://jenkins.tdr-management.nationalarchives.gov.uk/pluginManager
[script console]: https://jenkins.tdr-management.nationalarchives.gov.uk/script
