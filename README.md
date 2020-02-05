# tdr-dev-documentation
Documentation for developers for the Transfer Digital Records (TDR) project.

## TDR repos

The current repositories relating to TDR, and their purpose are:
- [tdr-jenkins](https://github.com/nationalarchives/tdr-jenkins) - Terraform scripts and Dockerfiles to create the Jenkins server and its build nodes.
- [tdr-terraform-backend](https://github.com/nationalarchives/tdr-terraform-backend) - Terraform scripts for setting up the Terraform backends in the TDR management account
- [tdr-terraform-environments](https://github.com/nationalarchives/tdr-terraform-environments) - Terraform scripts for provisioning AWS resources to support the TDR application within the different environments
- [tdr-transfer-frontend](https://github.com/nationalarchives/tdr-transfer-frontend) - Code for the TDR frontend to allow users to transfer files
- [tdr-consignment-api](https://github.com/nationalarchives/tdr-consignment-api) - API for managing consignment and file details
- [tdr-consignment-api-data](https://github.com/nationalarchives/tdr-consignment-api-data) - Migrations for the main TDR database
- [tdr-auth-server](https://github.com/nationalarchives/tdr-auth-server) - Jenkins and docker configuration to build and deploy the keycloak server.
- [tdr-e2e-tests](https://github.com/nationalarchives/tdr-e2e-tests) - End to end tests for TDR
- [tdr-aws-accounts](https://github.com/nationalarchives/tdr-aws-accounts) - AWS account level configuration

### Documentation repos

- [tdr-dev-documentation](https://github.com/nationalarchives/tdr-dev-documentation) - For TDR development documentation
- [tdr-design-documentation](https://github.com/nationalarchives/tdr-design-documentation) - Design decisions and wireframes

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

### Unused repos

- [tdr-prototype-terraform-modules](https://github.com/nationalarchives/tdr-prototype-terraform-modules)
- [tdr-prototype-terraform-stateful](https://github.com/nationalarchives/tdr-prototype-terraform-stateful)

## Documentation

* [Developer manual](manual/README.md): a guide for developers working on TDR
* [Technology considerations](technology-considerations/README.md): results of
  investigations into different technology choices for TDR

## Licence

Unless stated otherwise, the codebase is released under the [MIT
License](LICENCE). This covers both the codebase and any sample code in the
documentation.

The documentation is [© Crown copyright][crown-copyright] and available under
the terms of the [Open Government 3.0 licence][ogl].

[crown-copyright]: https://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/
[ogl]: http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
