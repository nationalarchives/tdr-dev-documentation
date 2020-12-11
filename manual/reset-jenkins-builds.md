# Reset Jenkins build numbers

Some of the TDR projects [get their deployment version numbers from the Jenkins
build number](../architecture-decision-records/0002-versioning-and-deployments.md).

Sometimes these numbers get out of sync. This might happen if Jenkins is
deployed without restoring a backup of the old build jobs, or if the backup is
out of date and doesn't include recent deployments.

In that case, you will see an error like this in the Jenkins job console:

```
05:55:52  To github.com:nationalarchives/tdr-consignment-api.git
05:55:52   ! [rejected]        v35 -> v35 (already exists)
05:55:52  error: failed to push some refs to 'git@github.com:nationalarchives/tdr-consignment-api.git'
05:55:52  hint: Updates were rejected because the tag already exists in the remote.
```

You can fix the issue by resetting the build number in Jenkins:

Go to the Jenkins script console at https://jenkins.tdr-management.nationalarchives.gov.uk/script

Run:

```
def job = Jenkins.instance.getItemByFullName("your-project-name/master")
job.nextBuildNumber = 1234
job.save()
```

Where `your-project-name` is the name of the Jenkins build, and `1234` is the
next available release tag.
