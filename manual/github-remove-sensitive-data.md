# Removing Sensitive Data From Github

In the event of including sensitive data in a commit to a Github repository use the following instructions.

## Local Commit Only

* Remove the commit using the command: `git reset --hard`; or
* Delete the local branch and start again

## Commit Pushed to remote Github or Included in Pull Request

1. Inform the rest of the development team to not make any commits to the affected repository until the sensitive data is removed.
2. Note down the following:
  * commit hash(es) where the sensitive data was committed;
  * the pull request(s) URL(s)
3. Take a backup of:
  * your current local repository;
  * the file(s) that have the sensitive data;
4. Follow the steps set out here: [remove sensitive data from a repository](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
  * Before force pushing to the remote temporarily disable the `main` branch protection rules on the repository to allow the force push
  * Make sure to do the steps relating to contacting Github support to remove the pull request including the pull request URL(s) and commit hash(es) noted down earlier
5. Once Github support have confirmed the pull request has been deleted:
  * inform the development team to rebase their local repositories from the clean version of repository on Github
6. Create a new pull request to reinstate the affected file(s) if required:
  * **NOTE**: make sure the new version of the file(s) do not contain the sensitive data!
7. Once satisfied that the repository is in the correct state delete the local backups of the original repository and affected file(s)
