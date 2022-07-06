# 24. Continuous integration service

**Date:** 2022-03-15

## Context
We need a continuous integration service. There are two main functions we need from the service.
* Test code changes before they are merged and deployed.
* Build our code and deploy it to the different services and environment the code runs in.

## Options considered
We have been using Jenkins for a couple of years now so one option was to carry on using that.

The other option we considered is using [GitHub actions](https://docs.github.com/en/actions).

## Decision
We have decided to move from Jenkins to GitHub actions. There are advantages and disadvantages to this move.

### Advantages

#### Server maintenance
Jenkins runs on an EC2 instance using multiple docker images and uses multiple plugins. These need to be kept up to date separately which takes up quite a lot of time. 
GitHub actions runs on a hosted service that is maintained by GitHub. Because of this there is less maintenance for the TDR team.

#### Cost
With Jenkins, we are paying for the EC2 instance, the load balancer, NAT gateway and the Fargate costs for running the nodes which is not insignificant. 
GitHub actions is free for public repositories. The majority of the TDR repositories are public and the default position is that all repositories should be public.
We don't have any builds running against private repositories. If we need them in the future, the nationalarchives GitHub organisation has credits we can use. 

#### Permissions management
We need to be able to control who can deploy code to different environments. Staging and production deployments should be limited to certain users. 
With Jenkins, we have done this by having a separate instance with separate permissions but this doubles the cost, and the maintenance needed. 
GitHub actions allows you to set necessary approvals for certain environments so only certain users can approve the deployments. This simplifies the permissions model.

#### Speed
We were using Fargate nodes to run our builds in Jenkins. These are slow to start so the builds are slow to run. 
GitHub actions runners start much faster which will speed up the builds slightly.
Also, running steps in parallel, on GitHub Actions, is much easier so we can speed up builds that way too.

### Disadvantages
#### Time to migrate
It will take time to move all of our CI jobs to GitHub actions. We should make this back from the time saved on server maintenance though.

#### Developer knowledge
All of the developers on the team will need to learn GitHub actions config and workflows and this will also take time.