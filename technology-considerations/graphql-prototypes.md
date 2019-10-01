# GraphQL prototypes

Date: 2019-08-29

After looking into [different options for the TDR API][api-options], we decided
to try GraphQL when building the API for the Proof of Concept phase.

We investigated two approaches: AWS AppSync and the Scala Sangria library. We've
decided on continuing with the Sangria approach because the development and
deployment environments are much easier to set up and maintain.

[api-options]: https://github.com/nationalarchives/tdr-dev-documentation/pull/4

## Context

TDR needs to store information on the state of consignments of files as they are
transferred to The National Archives. For example, it will store the original
file paths of files, along with their checksums and the result of virus scans.
The files themselves will be stored in [AWS S3][s3], and we've decided to [store
the rest of the data in a relational DB][db-choice].

Several systems need to be able to read and update the data:

- The TDR frontend (both in the browser and in server-side code)
- Background tasks that analyse uploaded files
- The export process which will save the file metadata

The API layer will provide a consistent interface for these clients to access
the data.

Whatever approach we take for the API, we would prefer to write any business
logic in Scala. The team developing TDR uses Scala and Java in our other
server-side applications, and we've chosen to keep using Scala for consistency.

[s3]: https://aws.amazon.com/s3/
[db-choice]: https://github.com/nationalarchives/tdr-dev-documentation/pull/7

## AppSync approach

[AWS AppSync][appsync] is a platform specifically for building GraphQL APIs, and
it can fetch data from multiple data sources including AWS RDS databases.

In AppSync, [GraphQL resolvers][resolvers] can be implemented in one of two
ways. Simple resolvers, which are just a wrapper for a single database table,
can use [Apache Velocity templates][velocity] to map between the GraphQL request
and the database. More complex resolvers, which implement business or
authorization logic, can be written as [pipeline resolvers][pipeline-resolvers],
which call arbitrary AWS Lambda functions.

We investigated this option because it sounded like it would save us setup and
deployment time, because request handling and database connections are built
into AppSync. In practice, though, we ran into a lot of problems.

[appsync]: https://aws.amazon.com/appsync/
[resolvers]: https://graphql.org/learn/execution/
[velocity]: https://docs.aws.amazon.com/appsync/latest/devguide/resolver-mapping-template-reference-programming-guide.html
[pipeline-resolvers]: https://docs.aws.amazon.com/appsync/latest/devguide/pipeline-resolvers.html

### Local development

It was fairly straightforward to set up an [AppSync
prototype][tdr-appsync-prototype] based on the [Serverless
Framework][serverless]. This connected to DynamoDB and just used Velocity to map
the data.

As mentioned above, we wanted to check that we could write business logic in
Scala. [Serverless supports Lambdas written in Java][serverless-java] (which
implies it also supports other JVM languages like Scala), but we weren't able to
set up a working dev environment that used both Java _and_ AppSync. It may well
be possible - we just decided it wasn't worth spending more time getting it to
work.

Writing pipeline resolvers also looks like it involves a lot of boilerplate
code, since every Lambda resolver requires at least four Velocity templates
(before and after the pipeline, and before and after each Lambda function).
We suspect that it would be difficult to maintain a mix of Velocity and pipeline
resolvers, since some code will inevitably be duplicated.

We looked into [AWS Amplify CLI][amplify] as an alternative, but it doesn't
appear to support Java Lambdas. It also looks quite rigid: it's designed to help
people develop a very specific stack (AppSync with React and mobile clients). We
want something more stack-agnostic so that we can integrate it with other TDR
services.

Developing an AppSync application without one of these framework looks
impractical because you would have to either build some way to run the templates
and the Lambda code together, or give up on local development and only run code
in an AWS environment.

One final reason disadvantage of AppSync is that it requires you to write Apache
Velocity templates. One of the developers on the team has used Velocity in
a previous project and found it very difficult to read, maintain and test.

[tdr-appsync-prototype]: https://github.com/nationalarchives/prototype-appsync
[serverless]: https://serverless.com/
[serverless-java]: https://serverless.com/blog/how-to-create-a-rest-api-in-java-using-dynamodb-and-serverless/
[amplify]: https://github.com/aws-amplify/amplify-cli

### Deployment

The Serverless Framework and Amplify both depend on [CloudFormation], which
would be tricky to fit in with our [Terraform configuration][tdr-terraform].

If we built our own deployment pipeline, it would have to deploy the Velocity
templates using the AWS API as well as deploying the Lambda code by copying
build artifacts.

[CloudFormation]: https://aws.amazon.com/cloudformation/
[tdr-terraform]: https://github.com/nationalarchives/tdr-prototype-terraform

### Hosting

Using AppSync would make the application extremely coupled to AWS
Infrastructure, because so much of the code would be in Velocity templates and
the rest would be implemented as AWS Lambdas.

### Database connection

It's straightforward to connect AppSync to DynamoDB, but we'd [prefer to use a
relational DB][db-choice] to store information about transfers.

To connect AppSync to a relational DB such as Aurora, you can either use a [Data
API][rds-data-api] or use a Lambda as a data source, both of which have
downsides.

[Data API is not currently available in eu-west-2][data-api-availability], and
we need to store data in the UK.

Lambda data sources suffer from cold starts, which may be even slower in a VPC
(although [AWS are rolling out a fix][lambda-vpc-improvements]).

[rds-data-api]: https://docs.aws.amazon.com/appsync/latest/devguide/tutorial-rds-resolvers.html
[data-api-availability]: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/data-api.html#data-api.regions
[lambda-vpc-improvements]: https://aws.amazon.com/blogs/compute/announcing-improved-vpc-networking-for-aws-lambda-functions/

## Sangria approach

As mentioned above, we prefer to use Scala as a backend language for consistency
with our other projects. [Sangria] looks like a mature and feature-rich
implementation of a GraphQL server in Scala, so we are using it to build a
[GraphQL API prototype][sangria-prototype]. It uses [Slick] to map the Scala
code to SQL queries.

### Local development

The development process is simple because it's just a single Scala application.
We've wrapped the Sangria code in an [akka-http] server for development, which
is quick to redeploy when modifying the code.

We've added several API endpoints so far, and it's been fairly straightforward
to build everything we need.

### Deployment and hosting

We've wrapped Sangria in a Lambda entry point for deployment, but we may switch
to using akka-http in production as well. In that case, we would probably deploy
a container to ECS, which we have experience of with the [TDR
frontend][tdr-mvc].

We currently deploy the application to Lambda by manually uploading a jar, but
we don't anticipate it being difficult to automate. If we switch to ECS (or even
a different hosting provider), we will deploy it in the same way as the TDR
frontend.

[Sangria]: https://sangria-graphql.org/
[sangria-prototype]: https://github.com/nationalarchives/tdr-prototype-sangria
[Slick]: http://slick.lightbend.com/
[akka-http]: https://github.com/akka/akka-http
[tdr-mvc]: https://github.com/nationalarchives/tdr-prototype-mvc

## Conclusions

Given how much easier it was to set up and develop a Sangria server than
AppSync, we've decided to continue using Sangria to build a GraphQL server.

## Client-side GraphQL experience

This document is mostly about the choice of GraphQL server, but we've also
learned a bit about GraphQL client libraries.

Sangria has been easy to work with as a Scala GraphQL server library, but we
haven't been able to find a good client library for Scala. The best option is
[Drunk], but it appears to be a very thin wrapper around an HTTP client and
the Circe JSON parser. You have to write graphQL queries as strings, with no
type safety to protect you from syntax errors or inconsistencies between the
code and the schema.

For now, we've chosen to just use an HTTP client library directly. This gives
us more control over the HTTP request, which is particularly useful when we need
to do things like [sign requests][iam-signing].

[Drunk]: https://github.com/Jarlakxen/drunk
[iam-signing]: https://docs.aws.amazon.com/apigateway/latest/developerguide/permissions.html
