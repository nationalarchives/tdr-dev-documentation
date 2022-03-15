# 24. Continuous integration service

**Date:** 2022-03-15

## Context
We need a continuous integration service. There are two main functions we need from the service.
* Test code changes before they are merged and deployed.
* Build our code and deploy it to the various different services and environments it runs in.

## Options considered
We have been using Jenkins for a couple of years now so one option was to carry on using that.

The other option we considered is using [GitHub actions](https://docs.github.com/en/actions).

## Decision
We have decided to move from Jenkins to GitHub actions. There are advantages and disadvantages to this move.

### Advantages

#### Server maintenance
Jenkins runs on an EC2 instance using multiple docker images and uses multiple plugins and all of these need to be kept up to date separately which takes up quite a lot of time. 
GitHub actions runs on a hosted service that is maintained by GitHub.

#### Cost
With Jenkins, we are paying for the EC2 instance, the load balancer and NAT gateway and the Fargate costs for running the nodes which is not insignificant. 
GitHub actions is free for public repositories.

#### Permissions management
We need to be able to control who can deploy code to different environments. Staging and production deployments should be limited to certain users. 
With Jenkins, we have done this by having a separate instance with separate permissions but this doubles the cost and the maintenance needed. 
GitHub actions allows you to set necessary approvals for certain environments so only certain users can approved the deployments.

#### Speed
We were using Fargate nodes to run our builds in Jenkins. These are slow to start so the builds are slow to run. 
GitHub actions runners start much faster which will speed up the builds slightly.
Also, running steps in parallel is much easier so we can speed up builds that way too.

#### Building code from forks
There is a service called Scala Steward which keeps Scala dependencies up to date by forking the repository and created a pull request. 
With our Jenkins setup, we weren't able to test code from forks, with GitHub actions, this is now possible.

### Disadvantages
#### Time to migrate
It will take time to move all of our CI jobs to GitHub actions. We should make this back from the time saved on server maintenance though.

