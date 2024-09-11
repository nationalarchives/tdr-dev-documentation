# Create a repo

## 1. Create Repo on GitHub

Create a repo in <https://github.com/nationalarchives> by clicking the "New" button

* The repo name should start with "tdr-", unless it's going to be used more widely
* The repo should be public unless you have a [good reason to make it closed][open-code]
* Click "Create Repository"

## 2. Add new repo to Synk

* Log into Synk via Github: 
* Switch to `nationalarchives` Organisation
* From the Homepage use the `Add projects` dropdown to select Github
* Find the new repo and add it to Synk (this can take a few moments to add the repo)

## 3. Add Terraform Secrets

If environment secrets are going to be needed in the workflow files (mentioned later), if you haven't already, you are going to have to define them in the `root_github.tf` file(s) of the Terraform projects:

### Add terraform backend secrets

Add a Terraform backend secrets module for your new repo to the `root_github.tf` file of the Terraform backend project [like so][terraform-backend-module-example] and make a PR for this change.

### Add terraform environment secrets

Add a Terraform secrets module for your new repo to the `root_github.tf` file of the Terraform environments project [like so][terraform-environments-module-example] and make a PR for this change.

## 4. Add a README

On the next page, steps should appear for how to create a repo via the command line, if they do follow those
instructions, if not, follow these instructions:

1. create a directory locally using the same name as you gave the repo (the one that starts with "tdr-")
2. `echo "# {name of repo}" >> README.md`
3. git init
4. git add README.md
5. git commit -m "Initial commit"
6. git branch -M main
7. git remote add origin `git@github.com:nationalarchives/{name of repo}.git`
8. git push -u origin main

## 5. Add a licence

In the parent directory add an open source licence with the name "licence"

* For code repos, add an MIT licence ([example][mvc-licence])
    * Make sure that the year specified is the current one
* For documentation, add an MIT licence for the code and an [Open Government Licence][ogl] for the content. See this
  repo's LICENCE file the licence note in the README for an example.

## 6. Add a config file

**If** the project contains a [dependabot supported package manager][supported-package-managers] then add
a [dependabot config file][dependabot-config]
to the `workflows` folder in the `.github` folder (create a .github folder if one doesn't exist). 

If the project doesn't contain a dependabot supported package manager, then skip this step.

## 7. Choose the correct settings for the repo

### 7a. Add teams

Once in the repo, click the "Settings" button (at the top) to update the repo's settings:

* Under "Collaborators and teams" you should see "Manage access":
* Select "Add teams"
    * in the search bar, type "Transfer Digital Records" and select it when it appears
        * give **write** access to this team
        * click the green "Add" button to add it
    * in the search bar, type "Transfer Digital Records Admins" and select it when it appears
        * give **admin** access to this team
        * click the green "Add" button to add it

### 7b. Automatically delete head branches

Go to "General" settings (as the top), and scroll down to "Automatically delete head branches" and select this

### 7c. Set rules for main branch

* In "Branches", you should see the "main" branch.
* Under "Branch protection rules" select "Add rule"
* For the "Branch name pattern", add the name "main"
* Select the following branch protection rule options for *main*:
    * **Require pull request reviews before merging**
        * "Require approvals" should be selected automatically which is fine *(the default of 1 required number of
          approvals is OK)*
    * **Dismiss stale pull request approvals when new commits are pushed**
    * For any repositories that use a multi-branch GitHub Actions pipeline the following additional branch protection
      rules should be set for the *main* rule:
        * **Require status checks to pass before merging**
            * **Require branches to be up-to-date before merging** *(sub option)*
                * **Note**: the GitHub Actions test job will need to be configured first before this status check will
                  appear; see step 7 (below) for more information on how to do this.
                * **Note**: Snyk should be added to this list if available for the repo.
    * **Require signed commits**
    * **Include administrators**
* Click the "Save changes" button

## 8. Add file dependencies

### 8a. Add workflow files

We use GiHub Actions in order to test, build and deploy our projects; since step 5 was all about requiring status checks,
the GitHub Actions files it runs, need to be added.

* In the repo, if there isn't already a `.github` directory, create one
* Within that `.github` directory, create a `workflows` directory
* copy the `build.yml`, `deploy.yml` and `test.yml` from a similar repo ([example][example-repo-workflow-files])
* For the build.yml
    * replace all instances of the older repo's name with the name of your repo
    * under `pre-deploy: > uses` change the [workflow][workflow-files] to the "build" workflow relevant for your repo
    * change the build command to run whatever commands the project needs to build
* For the deploy.yml
    * under `deploy: > uses` change the [workflow][workflow-files] to the "deploy" workflow relevant for your repo
* For the test.yml
    * under `jobs: > test: > with: > test-command: >` change the build test-commands to run whatever commands the
      project needs to test its code
* Once this is done, commit the files and push them to the repo; you will notice that the test job will start running
    * **Note**: In order to push to the repo, you'll need to create a new branch

### 8b. Add the files that the workflow files rely on

The workflow files might have a rule that runs a command like `sbt assembly`; in order for it to do that it would need
the `build.sbt` file to be present. Add the files that are necessary for the workflow files to run for example:

1. Dependencies
2. plugins.sbt
3. build.sbt
4. package.json

Make sure that each of the files you add, contain all the dependencies/commands necessary

## 9. Select status checks that are required before merging

* Go back to the repo and select the "Settings"
* Select "Branches"
* Under "Branch protection rules", click the "edit" button for the main branch that you created
* Under "Require branches to be up-to-date before merging" (that you selected previously), you should now see a search
  bar with the placeholder text "Search for status checks in the last week for this repository"
* type in "test / test" and select that status check option

## 10. Remove yourself from list of who can manage access

* Go to the "Settings"
* Under the "Manage access" section, you should see your account that has been given admin access
* Next to your account, Click "remove"
    * *Since you are either a part of the "Transfer Digital Records" or "Transfer Digital Records Admins", you will
      still have access rights to this repo*

## 11. Link other repos to project

* Add a link from the new project's README to this documentation, to add context for anyone who finds the project
* Add the new project to the repo list in the README of **this** project

## 12. Set up Scala Steward

If the project is a Scala project:

1. Create new branch in the repo: `scala-steward-dependencies`
2. Add new branch protection rule for the `scala-steward-dependencies` with the following rules:
    * **Require pull request reviews before merging**
        * "Require approvals" should be selected automatically which is fine *(the default of 1 required number of
          approvals is OK)*
    * **Dismiss stale pull request approvals when new commits are pushed**
    * **Allow specified actors to bypass required pull requests**
        * Select the relevant GitHub service account user
   * **Require status checks to pass before merging**
     * **Require branches to be up-to-date before merging** *(sub option)*
     * **Note**: the GitHub Actions test job will need to be configured first before this status check will
     appear; see step 7 (below) for more information on how to do this.
     * **Note**: Snyk should be added to this list if available for the repo.
   * **Require signed commits**
3. Add the repository to the [list of repos maintained by Scala Steward]   

## 13. Add the repo in the tdr-configurations
* Go to [github_repositories][github-repositories] and add your newly created repository to the list. If your repo starts with `tdr-` then add it in the `github_tdr_active_repositories` or if it starts with `da-`
then add it in the `github_da_active_repositories` list
  * Update the submodule hash for the tdr-configurations in the following repositories and then deploy the changes
  * [tdr-terraform-environments][terraform-environments]
  * [tdr-terraform-backend][terraform-backend]
  * [tdr-terraform-github][terraform-github]

[dependabot-config]: https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/enabling-and-disabling-version-updates

[example-repo-workflow-files]: https://github.com/nationalarchives/tdr-consignment-api/tree/master/.github/workflows

[supported-package-managers]: https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/about-dependabot-version-updates#supported-repositories-and-ecosystems

[open-code]: https://www.gov.uk/government/publications/open-source-guidance/when-code-should-be-open-or-closed

[mvc-licence]: https://github.com/nationalarchives/tdr-prototype-mvc/blob/master/LICENCE

[ogl]: http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/

[list of repos maintained by Scala Steward]: https://github.com/nationalarchives/tdr-github-actions/blob/main/repos.md

[terraform-backend-module-example]: https://github.com/nationalarchives/tdr-terraform-backend/blob/50be75b8a76d7a3694c38e5772ad689e743e7530/root_github.tf#L456

[terraform-environments-module-example]: https://github.com/nationalarchives/tdr-terraform-environments/blob/master/root_github.tf#L407

[workflow-files]: https://github.com/nationalarchives/tdr-github-actions/tree/main/.github/workflows

[github-repositories]: https://github.com/nationalarchives/tdr-configurations/blob/master/terraform/github_repositories.tf
[terraform-environments]: https://github.com/nationalarchives/tdr-terraform-environments
[terraform-backend]: https://github.com/nationalarchives/tdr-terraform-backend
[terraform-github]: https://github.com/nationalarchives/tdr-terraform-github
