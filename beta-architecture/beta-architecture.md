# Beta Architecture

The current architectural design for beta is shown below.

Diagram is available for editing here: https://www.lucidchart.com/documents/edit/caa0eee6-a9ef-4d2e-a03e-4a1d6fc7b7e4/0_0

This is not the final architecture, and it will change during the course of the beta phase of the TDR project.

![](./diagrams/tdr-beta-high-level-architecture.svg)

## AWS Accounts and TDR environments

TDR uses five AWS accounts:

* Management (mgmt): the top-level account, which is used for running
  cross-environment services like Jenkins CI and Grafana.
* Sandbox (sbox): used for technical spikes
* Integration (intg): the first environment that code is deployed to. Most
  services are deployed automatically to intg when code is merged to the
  main/master branch. Most deployments are run programatically through Jenkins,
  but we sometimes make temporary manual changes or deploy a branch when that's
  the easiest way to test something.
* Staging (staging): a more stable environment used to check changes just before
  deployment to production. Developers need to manually start a Jenkins job to
  deploy code to this environment. Used for user research sessions.
* Production (prod): the environment used by real users. Deployment is the same
  as for staging.

This diagram shows the interactions between the different AWS accounts:

![](./diagrams/aws-accounts.png)

### TDR

The applications which make up TDR run within each environments. For example,
each environment has a frontend application, API, auth server, etc.

### Initial assumptions

* We don't yet need to integrate TDR with any other systems, though we might
  reuse the login system to let department users view their own records
* Series and departments won't need to be updated very often, so for MVP it's OK
  for this to be a developer task, even though eventually we might build an
  admin UI or integrate with the planned catalogue API
* Data stored in the export bucket can be transferred to the preservation system
