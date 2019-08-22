# Travis vs Jenkins

## Travis

### Pros
* Very easy to integrate with github
* Hosted so no server infrastructure to manage
* Simple yaml config which is good for simple use cases.
* Free
* Nice UI

### Cons 
* Flaky. Seems to be prone to network issues so docker hub or the sbt repos can't be reached. 
* There is no easy way to do parameterised builds so we can re-use build logic for different use cases
* The containers which run the builds are very slow. On a basic sbt project, it can take over two minutes for a build. There is no way to speed up the containers, you can only run jobs in parallel which doesn't help if you have one slow running command. 
* There is no way to modify the yaml file and re-run a build without pushing to the branch again. 
* Secrets are stored in travis so we have to trust them. 

## Jenkins

### Pros
* We have complete control over our own secrets management. This does mean it's up to us to keep things secure but we can do that. 
* It uses groovy scripts which means we have much more control over complicated build processes. 
* It's hosted on AWS so network issues are unlikely. We also have control over the resources available for the build nodes, so resource intensive build processes can be run on faster machines. 
* There is a replay feature which allows you to test builds without constantly pushing to the repo. 
* Parameterised builds are easy. 
* Everyone has experience with Jenkins. 

### Cons
* Slightly more complicated to integrate with github but not much. 
* Not free. The costs depend but we'll need an EC2 instance running constantly to provide persistence, plus the cost of any ECS nodes running, plus the cost of a NAT gateway and load balancer to keep it secure.
* Setup is hosted on our own AWS. The setup can be as simple as we like. An EC2 instance with Jenkins installed is easy. If we want to have everything including slave nodes on ECS Fargate then it is much more complicated, although if this is done using configuration as code, it's not such a problem. 
* UI is from the 1990s

