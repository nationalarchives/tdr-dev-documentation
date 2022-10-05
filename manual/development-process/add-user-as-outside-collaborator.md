# Add a GitHub user as an outside collaborator on a repository

1. Add the GitHub username to the collaborators list in the [global parameters file](https://github.com/nationalarchives/tdr-configurations/blob/master/terraform/global_parameters.tf) in the tdr-configurations repo.
2. Create a pull request and merge after approval.
3. Update the submodules hash in [tdr-terraform-backend](https://github.com/nationalarchives/tdr-terraform-backend/)
4. Create a pull request and merge that.
5. Ask someone with admin access to run terraform in the tdr-terraform-backend project. 
