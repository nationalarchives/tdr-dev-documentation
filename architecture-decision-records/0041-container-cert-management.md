# Container TLS Certificate Management

# Status - WIP

# Context

We wish to implement end-to-end encryption (e2ee) for ECS based service.  Currently, we have TLS termination on the AWS Load Balancers.  Services behind these are served using a plain text protocol (HTTP).  We wish to change this to HTTPS.  Doing so, requires that certificates are installed on each running service.  Getting the certificates on to the containers requires a design decision which is discussed herein.  Not increasing new complexity to the local development experience must be considered.  Certificates only need to be self signed and can expire - [see](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html#target-group-routing-configuration)

At the time of writing, the services effected are:

* Consignment API

* Transfer Service

* Play Frontend

* Keycloak


# Design Option 1 - Sidecar that fetches secrets

An example of the Sidecar pattern can be found here [Sidecar pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/sidecar)

In this design, an additional container would be attached to ECS task/service at launch.  A simple service or script would run on this sidecar that would fetch a cert and a key from a secrets store (e.g. SSM or Secrets Manager) and copy them to a shared volume.  The existing service is configured to use the key and cert from this shared volume.

The sidecar would be a single and portable implementation and could be attached to all existing and future services that require TLS certs.

There is a medium level of engineering required and it introduces another service that must be maintained.

A small amount of change is required to the existing service to consume the key and cert from the shared volume.

# Design Option 2 - Sidecar proxy

A sidecar proxy solutions such as Envoy or a similar roll-your-own approach with nginx/apache http.

A proxy solution would potentially remove any need to make changes to the existing service and removes the need to install on them any certificates at all.

This requires a new service to be engineered and maintained.


# Design Option 3 - Shared Storage

In this design, each container is configured to attached to a shared storage mechanism (EFS, S3 files etc) where from it would read the cert and key.

A process or service for creating the certs and keys would need to be considered.

There is a medium amount of engineering required to the existing service to attach to the storage service.  Local development is also made more complex because of this requirement.

# Design Option 4 - Task Secret Injection and Conversion

An secrets manager arn is used to inject a value in to the Task Definition/Environment.  At launch, a process is engineered to convert the environment vars values to a key and cert on the filesystem.

There is a medium level of engineering required to do the conversion of vars to files.  This also makes the service more brittle and more complex and is not necessarily a generic process for all the services.

The local development experience would need to be considered if the user does not have access to the secrets.

# Design Option 5 - Bake Secrets in Dockerfile

Add a command in Dockerfile to create a certificate and key on build.

This is by far the simplest option, has little to no impact on the developer experience but it breaks the principal of shipping artefacts with baked in credentials.

# Design Option 6 - Generate Secrets on Boot with Entrypoint Script

When the container launches a certificate and key is created.  This is achieved by changing the ```ENTRYPOINT``` to become a shell script which generates the certificate and key and then executes the existing ```CMD``` to launch the service.  This pattern is described in [Building best practices](https://docs.docker.com/build/building/best-practices/#entrypoint)

There is little engineering effort required in this solution and the local development experience will remain unchanged or even improved.

This has the added benefit in that to rotate a certificate and key, the ECS task is simply restarted.

# Decision

We will use option 6 - Generate Secrets on Boot with entry point script

# Consequences

All services must be reconfigured use TLS on launch.

# Related tickets

TDRD-1405, TDRD-1808, TDRD-1809, TDRD-1810
