# tdr-dev-documentation
Documentation for developers for the Transfer Digital Records (TDR) project.

## TDR repos

The current repositories relating to TDR, and their purpose are:

### Core services

- [tdr-consignment-api](https://github.com/nationalarchives/tdr-consignment-api) - API for managing consignment and file details
- [tdr-transfer-frontend](https://github.com/nationalarchives/tdr-transfer-frontend) - Code for the TDR frontend to allow users to transfer files

### Auth

- [tdr-auth-server](https://github.com/nationalarchives/tdr-auth-server) - Jenkins and docker configuration to build and deploy the Keycloak server
- [tdr-auth-utils](https://github.com/nationalarchives/tdr-auth-utils) - A library of useful auth functions

### Frontend libraries

- [tdr-file-metadata](https://github.com/nationalarchives/tdr-file-metadata) - Library for extracting file metadata like client-side checksums

### Data migrations and backend libraries

- [tdr-aws-utils](https://github.com/nationalarchives/tdr-aws-utils) - Scala wrappers for AWS Java SDK methods used in TDR
- [tdr-consignment-api-data](https://github.com/nationalarchives/tdr-consignment-api-data) - Migrations for the main TDR database and Slick helper classes generated from the TDR schema
- [tdr-generated-graphql](https://github.com/nationalarchives/tdr-generated-graphql) - Generated case classes to use when querying the API
- [tdr-graphql-client](https://github.com/nationalarchives/tdr-graphql-client) - A simple scala client for connecting to the API

### File check tasks

- [tdr-antivirus](https://github.com/nationalarchives/tdr-antivirus/) - Task for scanning uploaded files for malware
- [tdr-api-update](https://github.com/nationalarchives/tdr-api-update/) - Task for sending the results of file checks to the API
- [tdr-checksum](https://github.com/nationalarchives/tdr-checksum/) - Task for calculating the server-side checksum of uploaded files
- [tdr-download-files](https://github.com/nationalarchives/tdr-download-files/) - Task for transferring a file from S3 to EFS, where it can be used by the rest of the file checks
- [tdr-file-format](https://github.com/nationalarchives/tdr-file-format/) - Task for determining the format of uploaded files

### Export steps

- [tdr-consignment-export](https://github.com/nationalarchives/tdr-consignment-export) - Task for exporting a consignment from TDR
- [tdr-consignment-export-authoriser](https://github.com/nationalarchives/tdr-consignment-export-authoriser) - Lambda which authorises a request to export a consignment

### Infrastructure and deployment

- [tdr-aws-accounts](https://github.com/nationalarchives/tdr-aws-accounts) - AWS account level configuration
- [tdr-configurations](https://github.com/nationalarchives/tdr-configurations) - Private repository for configuration files and parameters
- [tdr-ecr-scan](https://github.com/nationalarchives/tdr-ecr-scan) - Task which starts an ECR image scan for Docker images which are currently in use
- [tdr-ecr-scan-notifications](https://github.com/nationalarchives/tdr-ecr-scan-notifications) - Task which sends alerts when ECR scans detect a Docker image vulnerability
- [tdr-jenkins](https://github.com/nationalarchives/tdr-jenkins) - Terraform scripts and Dockerfiles to create the Jenkins server and its build nodes.
- [tdr-jenkinslib](https://github.com/nationalarchives/tdr-jenkinslib) - Shared groovy scripts for TDR jenkins jobs.
- [tdr-terraform-backend](https://github.com/nationalarchives/tdr-terraform-backend) - Terraform scripts for setting up the Terraform backends in the TDR management account
- [tdr-terraform-environments](https://github.com/nationalarchives/tdr-terraform-environments) - Terraform scripts for provisioning AWS resources to support the TDR application within the different environments
- [tdr-terraform-modules](https://github.com/nationalarchives/tdr-terraform-modules) - Terraform modules for use by other Terraform repositories
- [tna-custodian](https://github.com/nationalarchives/tna-custodian) - Implementation of Cloud Custodian for National Archives

### Monitoring

- [tdr-grafana](https://github.com/nationalarchives/tdr-grafana) - Implementation of Grafana for TDR

### Testing

- [tdr-e2e-tests](https://github.com/nationalarchives/tdr-e2e-tests) - End to end tests for TDR

### Local development

- [tdr-local-aws](https://github.com/nationalarchives/tdr-local-aws) - Emulate backend file checks in the development environment

### Documentation repos

- [tdr-dev-documentation](https://github.com/nationalarchives/tdr-dev-documentation) - For TDR development documentation
- [tdr-design-documentation](https://github.com/nationalarchives/tdr-design-documentation) - Design decisions and wireframes

### Prototype repos

Prototypes and proofs of concept built during the Beta phase:

- [tdr-prototype-json-logging](https://github.com/nationalarchives/tdr-prototype-json-logging) - Prototype of a Scala application which writes logs in a JSON format
- [tdr-interactive-prototype] (https://github.com/nationalarchives/tdr-interactive-prototype) - Interactive Prototype using the GOV.UK Prototype Kit

### Alpha prototype repos

Repos that were part of the final Alpha prototype:

- [prototype-terraform](https://github.com/nationalarchives/prototype-terraform) - For prototyping with Terraform
- [tdr-prototype-sangria](https://github.com/nationalarchives/tdr-prototype-sangria) - Prototype GraphQL server written in Scala with Sangria
- [tdr-prototype-mvc](https://github.com/nationalarchives/tdr-prototype-mvc) - Prototype Play MVC app
- [tdr-prototype-file-export](https://github.com/nationalarchives/tdr-prototype-file-export) - Prototype of file export for digital archivists
- [prototype-state-machine](https://github.com/nationalarchives/prototype-state-machine) - Prototype of file check tasks, like checksum calculation
- [tdr-prototype-wasm-checksum](https://github.com/nationalarchives/tdr-prototype-wasm-checksum) - Prototype of checksum calculations in WebAssembly
- [prototype-tdr-jenkins](https://github.com/nationalarchives/prototype-tdr-jenkins) - Infrastructure-as-code for Jenkins

Other ideas that we prototyped, but which didn't form part of the final system:

- [prototype-frontend-next](https://github.com/nationalarchives/prototype-frontend-next) - Prototype of the frontend in Next.js
- [prototype-front-end](https://github.com/nationalarchives/prototype-front-end) - Prototype of the frontend in React
- [prototype-cypress](https://github.com/nationalarchives/prototype-cypress) - Prototype of Cypress tests for TDR
- [prototype-graphql](https://github.com/nationalarchives/prototype-graphql) - Prototype GraphQL server written in Node.js with Apollo Server
- [prototype-appsync](https://github.com/nationalarchives/prototype-appsync) - Prototype AWS AppSync Graphql server
- [prototype-server](https://github.com/nationalarchives/prototype-server) - Prototype REST API

### Unused repos

- [tdr-prototype-terraform-modules](https://github.com/nationalarchives/tdr-prototype-terraform-modules)
- [tdr-prototype-terraform-stateful](https://github.com/nationalarchives/tdr-prototype-terraform-stateful)

## Documentation

* [Developer manual](manual/README.md): a guide for developers working on TDR
* [Technology considerations](technology-considerations/README.md): results of
  prototypes and spikes into different technology choices for TDR
* [Architecture decision records](architecture-decision-records/README.md):
  technical decisions that we make while building the production system

## Licence

Unless stated otherwise, the codebase is released under the [MIT
License](LICENCE). This covers both the codebase and any sample code in the
documentation.

The documentation is [© Crown copyright][crown-copyright] and available under
the terms of the [Open Government 3.0 licence][ogl].

[crown-copyright]: https://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/
[ogl]: http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
