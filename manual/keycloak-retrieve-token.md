# Keycloak: Retrieve Authorisation Tokens

Based on the following blog post: https://medium.com/@bcarunmail/securing-rest-api-using-keycloak-and-spring-oauth2-6ddf3a1efcc2

## Authorisation Token 

The Keycloak OpenID Connection configuration URL to get details about all security endpoints is: 
`GET https://{keycloak url}/auth/realms/{realm name}/.well-known/openid-configuration`

So for example for locally running TDR Keycloak this would be: `http://localhost:8081/auth/realms/tdr/.well-known/openid-configuration`

Important URLS returned from the response are:
* *issuer*: `https://{keycloak url}/auth/realms/{realm name}`
* *authorization_endpoint*: `{issuer}/protocol/openid-connect/auth`
* *token_endpoint*: `{issuer}/protocol/openid-connect/token`
* *token_introspection_endpoint*: `{issuer}/protocol/openid-connect/token/introspect`
* *userinfo_endpoint*: `{issuer}/protocol/openid-connect/userinfo`
 
Response also contains grant types and scopes supported:
* *grant_types_supported*: ["client_credentials", …]
* *scopes_supported*: ["openid", …]

## Retrieving Authorisation Token With Postman

When developing locally on the TDR API it is useful to use Postman to check GraphQl queries function correctly.

To do this Postman will require an authorisation token from Keycloak. Postman can be configured to retrieve authorisation token as follows:

1. Have Keycloak running locally and setup correctly for the TDR application with valid users
2. Open Postman
3. In your Postman request go to the Authorisation tab
4. Click the “Get New Access Token” button
5. In the dialog box fill in the fields as follows:

 * *Token Name*: keycloak-bearer-token
 * *Grant Type*: Authorization Code
 * *Callback URL*: http://localhost:9000 *[or whatever is the call back url for the Keycloak client that is being used]*
 * *Auth URL*: http://localhost:8081/auth/realms/tdr/protocol/openid-connect/auth *[or whatever is the authorisation url for the Keycloak client that is being used]*
 * *Access Token URL*: http://localhost:8081/auth/realms/tdr/protocol/openid-connect/token *[or whatever is the access token url for the Keycloak client that is being used]*
 * *Client ID*: tdr
 * *Client Secret*: *[the TDR client secret in Keycloak]*
 * *Scope*: (Doesn't matter - can be left blank)
 * *State*: 12345
 * *Client Authentication*: Send client credentials in body

6. Click “Request Token” in the dialog box
7. A Keycloak login screen should open up, and you need to enter the user credentials, just as if the user was logging into the TDR app
8. After a little wait a token will be returned to Postman which can then use to make queries to the TDR API

There is no way to save this configuration, which makes it tricky to when you want to fetch auth tokens from multiple environments. As a workaround, you can use a [combination of environment variables and Postman environments][switch-envs] to let you switch between TDR environments.

[switch-envs]: https://github.com/postmanlabs/postman-app-support/issues/4636#issuecomment-462055383
