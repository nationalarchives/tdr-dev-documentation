# 5. User authentication

**Date**: 2020-03-03

## Context

Several different types of user will need to use the Transfer Digital Records
frontend. For example, a user from a transferring body (such as another
government department) will need to log in to upload records. Some users, such
as departmental record officers or digital archivists, may need wider access to
view in-progress transfers started by other users.

One of the main features of TDR is the upload of large volumes of files to an S3
bucket, so the authentication system should also let us authenticate requests to
S3, ideally directly rather than proxying the uploads through another service.

TDR data also needs to be read and updated by background processes, such as the
file checks that happen when a file is uploaded. These machine clients will also
need to authenticate themselves.

Ideally, we would use an existing user management system as a federated identity
provider so that we don't have to support and administrate our own system. It
would also be easier for users, because they would not have to manage another
user account just for TDR. But we're not aware of a cross-government identity
provider (other than [GOV.UK signon][signon], which is only for
https://www.gov.uk), so our plan is to build our own for TDR.

Although we're focusing on TDR at the moment, we might want to use the same user
management system in future systems, such as an access system to let government
users see their own records. We expect that it will be simpler for users if they
have one account for both systems.

See the Alpha notes on [user management in cognito][alpha-cognito] for some more
context about what we expect a user management system to support, both for TDR
user and admin users. It was written early in the Alpha before we looked into
alternatives to AWS Cognito, but a lot of the context is still relevant.

[signon]: https://github.com/alphagov/signon
[alpha-cognito]: https://github.com/nationalarchives/tdr-dev-documentation/blob/master/technology-considerations/user-management-in-cognito.md

## Options

- [AWS Cognito][cognito]
- An OAuth2 SaaS service like [Auth0] or [Okta]
- A self-hosted open source OAuth2 service like [Keycloak]
- A custom-built user system

[cognito]: https://aws.amazon.com/cognito
[Auth0]: https://auth0.com
[Okta]: https://www.okta.com
[Keycloak]: https://www.keycloak.org

## Decision

Use Keycloak, and host it in AWS with the other TDR services.

We chose an OAuth2 service because it will allow us to authenticate different
TDR services, and allow us to reuse the user system in any future projects that
have the same user base. Building our own service is not worth the time or the
security risk.

We chose Keycloak over the SaaS options mainly based on cost, despite the extra
maintenance burden of hosting the service. If we had chosen a SaaS option, we
would have had choose one of the more expensive tiers to take advantage of extra
security features, and this wasn't worth it for the small user base on TDR.

We chose Keycloak over AWS Cognito for a few reasons:

- Completely customisable login page, so we can use the same styling on the
  login page as on the rest of TDR.
- Keycloak provides [service accounts], which are accounts that can be used by
  machine clients like the TDR backend tasks which the API can authenticate and
  authorize in exactly the same way as user tokens. There is no equivalent in
  Cognito, so we would have had to find an alternative solution.
- Keycloak has a built-in admin user interface. We may have to build our own
  interface for non-technical TNA users eventually, but with Cognito we would
  have had to have built it much earlier.
- Cognito does not support [silent authentication], which is an OAuth2 flow
  that removes the need to store refresh tokens in the browser. This is riskier
  than storing temporary access tokens. See these the GitHub issues in
  [amazon-cognito-auth-js] and [amplify-js] for more.

See the [Alpha notes on authentication][alpha-considerations] for a detailed
comparison of all the options.

As mentioned above, we will use Keycloak's built-in admin UI, and we will use
[service accounts] to generate tokens for backend tasks to authenticate with the
API.

We will authenticate file uploads by connecting Keycloak to an AWS Cognito
identity pool which has permissions to save files in the S3 upload bucket. We
have already prototyped this in the Alpha phase.

[service accounts]: https://github.com/keycloak/keycloak-documentation/blob/master/server_admin/topics/clients/oidc/service-accounts.adoc
[silent authentication]: https://auth0.com/docs/api-auth/tutorials/silent-authentication
[amazon-cognito-auth-js]: https://github.com/aws/amazon-cognito-auth-js/issues/92
[amplify-js]: https://github.com/aws-amplify/amplify-js/issues/1218
[alpha-considerations]: ../technology-considerations/authentication_authorisation_considerations.md
