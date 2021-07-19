# Jenkins Network Diagram

![text][diagram]

[diagram]: Jenkins.svg "Jenkins Network Diagram"
[repository]: https://github.com/nationalarchives/prototype-tdr-jenkins

There is an EC2 instance attached to the ECS cluster. We can't run Jenkins as a Fargate container as Fargate doesn't allow persistent storage between container restarts without some very hacky workarounds.

The ECS service runs a task. The image is based on the official Jenkins image with some extra configuration to install plugins and set up security. There is a [repository] for this.  

Route 53 forwards incoming requests to cloudfront which sends them to a network load balancer which sends it into the private subnet. 