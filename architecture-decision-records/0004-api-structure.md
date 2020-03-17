# 4. API structure

**Date**: 2020-03-03

## Context

TDR will store information about consignments and files in a relational
database. This needs to be updated when a user makes a change in the TDR
frontend, or after backend processing (e.g. with the results of an antivirus
scan). Rather than connect each of these applications to the database, which
has several disadvantages (e.g. requiring multiple applications to have a secure
DB connection and coupling them to the DB structure), we are building an API
which can be called by the other applications in TDR.

During the Alpha prototyping phase, we looked into the options of building the
API using a REST or GraphQL style. See our Alpha notes on [GraphQL vs
REST][graphql-vs-rest] and [GraphQL prototypes][graphql-prototypes].

The full [API for the Alpha prototype][prototype-api] was built in GraphQL,
using the [Scala Sangria library][sangria]. We did not prototype a REST API
because all the developers on the team were familiar with REST from previous
projects.

[graphql-vs-rest]: ../technology-considerations/API_management_AppSync_GraphQL_REST.md
[graphql-prototypes]: ../technology-considerations/graphql-prototypes.md
[prototype-api]: https://github.com/nationalarchives/tdr-prototype-sangria
[sangria]: https://sangria-graphql.org/

## Decision

Use GraphQL in the TDR Beta phase.

We found Sangria straightforward to work with on the Alpha prototype. It was
simple to define fields, generate a GraphQL schema and add [deferred resolvers]
to avoid overfetching.

There is a lack of mature GraphQL client libraries in Scala, but we came up with
a working approach in the [prototype][prototype-frontend] of [defining individual
queries][prototype-queries] and validating them against the schema using
[sbt-graphql].

The TDR API is an internal API, and is very likely to stay that way because TDR
is just a temporary record store. Once they have been transferred to TNA, they
will be moved to the preservation system and (eventually) an access system to
let people see the data. That access system may well have a public API, but the
data will not come directly from TDR, so we don't expect the choice of TDR API
to constrain future APIs.

This makes the TDR API a good candidate for testing a slightly more experimental
approach (GraphQL) rather than the well-established pattern (REST), without
impacting other systems if it turns out to be harder to work with. We're aware
of other government departments who are considering GraphQL, so this is a also a
good opportunity to share what we learn with other developers across government.

Some of the team still have some concerns around GraphQL, particularly around
error handling: REST has well-established conventions around error codes, which
are usually understood by other layers such as caching. GraphQL allows more
fine-grained error handling, but we will have to decide on custom errors and
handle them in the client applications. We will keep an eye on this in Beta and
see how it works in practice.

[deferred resolvers]: https://sangria-graphql.org/learn/#deferred-value-resolution
[prototype-frontend]: https://github.com/nationalarchives/tdr-prototype-mvc
[sbt-graphql]: https://github.com/muuki88/sbt-graphql
[prototype-queries]: https://github.com/nationalarchives/tdr-prototype-mvc/tree/master/app/graphql
