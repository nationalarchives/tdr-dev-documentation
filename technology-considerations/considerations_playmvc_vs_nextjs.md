# Front end technology considerations

## Ease of development

### Play
#### Advantages
* Very easy to run a debugger against
* Easy to run locally
* More advanced ecosystem with libraries to take care of authentication among other things.
* Better default stack traces
* Everyone on the team is familiar with Java/Scala

#### Disadvantages
* May have to duplicate rendering for components with JS enhancement (rendered once server-side and
then again in a React component)
* The full app needs to be released for any change, including minor front end fixes.
* Mixed languages (Scala & JS) in the same project means running linting tools is a tiny bit more
complex.

### Next JS + Separate API (Next JS Frontend API)
#### Advantages
* Easy and cheap to deploy to a hosted dev environment
* The NextJS API (which does the Controllers' job) can be written in any language so we can use the
language most appropriate for the task.
* A single project can use a single testing framework which should make CI testing and local testing
slightly easier.
* If you're developing the next js app, you get hot reloading which makes development faster.

#### Disadvantages
* Next js isn't typically used for progressively enhanced sites. There are at least two things which will
need extra development time.
* CSRF tokens
* Error pages
* Server side requests and client side components are in the same component.
* Authentication is mostly hand rolled inside a custom lambda/ inside HOC, which may be difficult to
maintain. We can also use API gateway custom authorisers which will solve some of these issues.

* More complex local development as the front and back end are separate. This can be solved with
docker containers but this adds an extra layer of complexity keeping these up to date.

## Software Evaluation

### Play
* Open Source
* Created 2007
* Customers include HMRC, LinkedIn, Samsung, EA and The Guardian
* Minor releases every 3 - 4 months, patch releases every month or less.

### Next JS
* Open Source
* Created 2016
* Customers include GitHub, Netflix, Uber, Docker
* Minor releases every month and major releases every 3 - 4 months.

In short both of these platforms are well established, well maintained and well used by some large
companies and unlikely to be abandoned.]

## Infrastructure

### Play

#### Disadvantages

* Need Ansible/Puppet or similar to configure the EC2 machine or Docker with ECS
* Applying OS updates is more difficult for EC2 and would be hard to automate. It is easier for ECS
because you only need to update the docker container.
* Need load balancer or deployments will have downtime (though this could just be nginx on the server)
* It needs an instance running all of the time, even when it's not being used (you can make it a small one
and rely on autoscaling)
* The network setup is much more complex. We need to decide how we want to set up the VPCs, the
subnets and security groups, whether or not we need a NAT gateway or not and a few other choices.
This will then need to be implemented and described in Terraform/CloudFormation.
* Adding servers for dev and test costs just as much as the original servers.
* Deployment is more difficult without causing downtime. CD pipelines are more complex.
* With a single server, there is a single point of failure, if the app is down, nothing will work.

## Scaling

This is related to how well the platform each app is deployed on will respond to spikes in traffic,
assuming that for most of the time, we're running this on the lowest spec hardware there is. Anyway, the
front end is not the bottleneck.

### Play

We have two deployment options here although the advantages and disadvantages are the same.
#### EC2 and ECS, Auto scaled with load balancer

#### Advantages

* We can run a very small instance all of the time, and then if there are spikes, the auto scaler will spin
up another instance.

#### Disadvantages
* It takes time to spin up a new EC2 instance or a new ECS task, from testing, this will be around 5
minutes.
* It's possible to have a condition where the load balancer terminates the first running task/instance
before the auto scaler has spun up a new one but this would only be with extremely high traffic, when
using the lowest possible hardware for the initial tasks. This is unlikely.

### Next JS + Separate REST API

#### Lambdas + API Gateway

#### Advantages
* There is nothing to set up to scale up in case of a spike in traffic. AWS will just spin up more lambdas.
* Starting new lambdas is much faster than spinning up a new instance/task.
* There are no servers to access and any external resources are accessed via http so there is no
network setup.
* Adding new environments is fast and costs nothing while not running.
* Deployments cause no downtime.

#### Disadvantages

* There is a small delay with cold start lambdas but if these are outside a VPC, they are negligable.
* There is a limit of 1000 concurrent running lambdas for free. This roughly equates to 150 - 200
concurrent users which seems unlikely.

## Performance
I've not run any specific tests but from manual testing, they are both fast and responsive so there's little
to no difference here.

## Costs
These are based on worst case scenarios. For example, this assumes that we do use a NAT gateway
and we have at least one server for dev and that we use more than the free tier 1 million lambda
requests.

### EC2 per environment
| Resource | Cost per month |
| ------------- |:-------------- |
| t3 micro prod | $9 |
| NAT Gateway | $36 |
| Load Balancer | $20 |
| Total | $65 |

We need at least three environments (prod, test, dev)
There will be additional cost that we don't anticipate now.

### ECS
| Resource | Cost per month |
| ---------------------------- |:-------------- |
| 0.25 CPU 0.5GB Container Prod| $9 |
| Load Balancer | $20 |
| Total | $29 |
We need at least three environments (prod, test, dev)
There will be additional cost that we don't anticipate now.

### Lambda + Gateway
| Resource | Cost per month |
| -------------------------------- |-------------- |
| First million lambda calls | $0 |
| One million extra calls | $0.40 |
| API Gateway one million requests | $3 |
| Total | $3.40 |
Additional environments will not cost you.
Still, there may be additional cost that we don't anticipate now.

None of these costs are prohibitive and there's a good chance we won't need the nat gateway but from
these worst case scenarios, ECS is over 10 times more than lambda + gatway and ec2 is 20 times more.