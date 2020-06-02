# Create a repo

* Create a repo in <https://github.com/nationalarchives>
  * The repo should be public unless you have a [good reason to make it
    closed][open-code]
  * The repo name should start with "tdr-", unless it's going to be used more
    widely
* Update the repo's settings:
  * In "Manage access":
    * give **write** access to the "Transfer Digital Records" team
    * give **admin** access to the "Transfer Digital Records Admins" team
  * In "Options", check "Automatically delete head branches"
  * In "Branch", add a branch protection rule for the *master* branch with the following options selected:
    * **Branch name pattern**: master
    * **Require pull request reviews before merging** *(default 1 review is OK)*
    * **Dismiss stale pull request approvals when new commits are pushed**
    * **Include administrators**
    
    For any repositories that use a multi-branch Jenkins pipeline the following additional branch protection rules should be set for the *master* rule:
    * **Require status checks to pass before merging**      
      * **Require branches to be up to date before merging** *(sub option)*
      
      Choose the following status checks:
      * **TDR Jenkins build status** *(make this a required check)*
      
      **Note**: the Jenkins job will need to be configured first before this status check will appear.
      
* Add an open source licence
  * For code repos, add an MIT licence ([example][mvc-licence])
  * For documentation, add an MIT licence for the code and an [Open Government
    Licence][ogl] for the content. See this repo's LICENCE file the licence note
    in the README for an example.
* Add a link from the new project's README to this documentation, to add context
  for anyone who finds the project
* Add the new project to the repo list in the README of this project

[open-code]: https://www.gov.uk/government/publications/open-source-guidance/when-code-should-be-open-or-closed
[mvc-licence]: https://github.com/nationalarchives/tdr-prototype-mvc/blob/master/LICENCE
[ogl]: http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
