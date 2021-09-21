# 7. Restricting User Access To S3 Objects

**Date:** 2020-04-01

This decision has been superseded by decision: [0022 Proxy S3 uploads through CloudFront](0022-cloudfront-upload-proxy.md)

## Context

Ensure that TDR users are not able to overwrite/view another user’s objects in the TDR AWS S3 upload bucket.

Potential options to resolve the problem are to use:
* AWS Cognito;
* Signed URLS.

## Decision

Decided to go with AWS Cognito, with Keycloak as an OpenId authentication provider, using IAM policy to restrict access to a user's objects.

AWS Cognito has some advantages over using signed URLs:
* Using signed URLs means an eavesdropper, potentially, can grab the signed url and use it until it expires
  * Note: AWS signed URLs use HTTPS, so an eavesdropper on a public network cannot see the secret part which is in the request parameters or the path.
* AWS Cognito will work with AWS KMS encrypted AWS S3, can set up an AWS IAM or key policy allowing access to the AWS KMS key from AWS Cognito identities
* A separate signed URL would have to generated for each file. That would mean generating thousands of URLs for large consignments.

Details of how AWS Congito would work are given in the sections below.

## Using AWS Cognito and Keycloak to Restrict Access to AWS S3 Bucket Objects

### AWS IAM Policy To Restrict Access to AWS S3 Bucket Objects

The following AWS IAM policy is an example of using an AWS Cognito identity sub parameter to control access to AWS S3 bucket objects.

Note: The `cognito-identity.amazonaws.com:sub` refers to the identity id associated with the user in the AWS Cognito Identity Pool.

```
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "WriteYourObjects",
                "Effect": "Allow",
                "Action": "s3:PutObject",
                "Resource": ["arn:aws:s3:::{bucket-name}/${cognito-identity.amazonaws.com:sub}/*"]                
            }
        ]
    }
```

This policy restricts the listing of AWS S3 objects that contain a prefix including the identity id of the user.

See the following for more details: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_s3_cognito-bucket.html

### Using AWS IAM Policy With TDR

TDR is using Keycloak to manage and authenticate users.

To be able to make use of an IAM policy outlined above to control access to AWS S3 objects, Keycloak needs to be integrated with AWS Cognito as an identity provider.

This is because Keycloak users will need to be associated with an AWS Cognito identity, which can be used with the AWS IAM policy.

Keycloak can be made an AWS Cognito authentication provider in two ways as:
* a custom Developer authentication provider; or
* an OpenId authentication provider.

Details of how to set up an AWS Cognito identity pool using these two approaches are available here:
* Custom Developer Authentication provider: https://docs.aws.amazon.com/cognito/latest/developerguide/developer-authenticated-identities.html
* OpenId Authentication provider: https://docs.aws.amazon.com/cognito/latest/developerguide/open-id.html

There is additional detail on the authentication flow for both approaches available here: https://docs.aws.amazon.com/cognito/latest/developerguide/authentication-flow.html

For the spike examples of using both methods were used. This was because the custom method was quicker to set up initially to help prove the IAM policy would restrict access to a user’s AWS S3 objects.

For production the OpenId method should be used as this is standards based.

### Practical Example

Outline of steps:
1. Create AWS S3 bucket
2. Set up Keycloak as an OpenId authentication provider in AWS IAM
3. Set up AWS Cognito Identity pool using Keycloak as an authentication provider
4. Create IAM policy restricting access to S3 objects prefixed with an AWS Cognito identity id
5. Associate the IAM policy with the authenticated IAM role associated with the AWS Cognito Identity pool

#### AWS Setup (Sandbox Account)

In the AWS Sandbox account two AWS Cognito identity pools created to use Keycloak as a custom and OpenId authentication provider:
* *Custom*: tkTest
* *OpenId*: tkTestOIDC

An AWS IAM policy created to restrict access to objects in an AWS S3 bucket based on the user’s associated identity from the respective AWS Cognito Identity pool: tkTestS3LimitAccessCognito

The policy was attached to the IAM roles associated with the identity pools authenticated identities.

To enable the AWS IAM policy to work the following S3 object prefix structure was implemented: `{Cognito Identity Id value}/sub prefixes …`

The following TDR Transfer Frontend branch uses two functions in the `SeriesDetailsController.scala` to demonstrate the restricted access in practice: https://github.com/nationalarchives/tdr-transfer-frontend/tree/cognitoDeveloperAuthProvider

Both functions add an object to the S3 bucket and list the objects with a prefix matching their AWS Cognito Identity Id value.

To run the branch the following environment variables need to be set:
* AUTH_URL={auth url for the intg environment}
* SANDBOX_ACCOUNT_NUMBER={AWS sandbox account number}
* TEST_BUCKET_NAME={name of the s3 bucket}
* API_URL={api url for the intg environment}
* DEV_PROVIDED_IDENTITY_POOL_ID={dev provided identity pool id}
* OIDC_IDENTITY_POOL_ID={oidc Cognito identity pool id}
* OIDC_PROVIDED_LOGINS_KEY={oidc provider logins key}
* DEV_PROVIDED_LOGINS_KEY={dev provider logins key}
* AUTH_SECRET={intg env auth secret}

Note: An AWS IAM user created to provide access to the AWS Cognito client

### Setting up Keycloak As An OpenId Authentication Provider In AWS Cognito

In order to set up Keycloak as an OpenId Authentication Provider do the following:
1. Obtain the root CA thumbprint for Keycloak.
* See the following guide: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
2. Set up Keycloak as OIDC Identity provider in AWS Cognito using the AWS CLI (there is currently a bug with doing it through the AWS console)
* See the following guide: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html#manage-oidc-provider-cli
* Note when providing the `url` argument for the `create-open-id-connect-provider` AWS CLI command this should be in the form: `{keycloak url}/auth/realms/tdr`

## Useful Documents:
* https://aws.amazon.com/blogs/security/writing-iam-policies-grant-access-to-user-specific-folders-in-an-amazon-s3-bucket/ (in depth look at using IAM policies to restrict access to S3 bucket objects. Concentrates on AWS console access, but still relevant)
