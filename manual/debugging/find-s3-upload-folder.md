# Find S3 upload folder

When you upload files to TDR, they are saved to the dirty bucket
(`tdr-upload-files-dirty-<environment>`). Within the bucket, the S3 object key
structure is like this: `<cognito-user-id>/<consignment-id>/<file-id>`, e.g.
`eu-west-2:56f64881-67ca-4657-87dc-3065a6ce3b20/01573ee9-05f6-4a1c-9bd4-b26020bebe1a/764996b2-57cc-431e-b6f2-65ae4ecda3fa`.

The reason for the top-level folder based on the Cognito user ID is that it lets
us set user-specific access permissions. See [ADR 7] for more details.

The folder structure does make it tricky to find a specific file in S3, because
you have to know all three IDs. You can find the consignment ID from the URL in
TDR. You can look up the file IDs in the database or monitor the API requests
made by the frontend JavaScript when it saves the file metadata.

The Cognito user ID is much harder to work out, because it is not stored in TDR.
It is generated by the frontend JavaScript to use when authenticating the file
upload requests.

Unfortunately, we don't know of a simple way to map between all Keycloak and
Cognito IDs, but you can look up the Cognito ID for your own test user.

First, get an authorisation token for the frontend client using Postman. You can
follow the normal steps to getting a token in [Retrieve Authorisation Tokens],
but you have to change the client ID to `tdr-fe`.

Then run the AWS CLI command:

```
aws cognito-identity get-id --identity-pool-id <identity-pool-id> --logins auth.tdr-integration.nationalarchives.gov.uk/auth/realms/tdr=<auth-token>
```

replacing `<auth-token>` with the token you got from Postman,
`<identity-pool-id>` with the Cognito identity pool ID (which you can look up
in the console or by running `aws cognito-identity list-identity-pools --max-results 10`).

[ADR 7]: ../../architecture-decision-records/0007-s3-user-access-to-objects.md
[Retrieve Authorisation Tokens]: ../keycloak-retrieve-token.md
