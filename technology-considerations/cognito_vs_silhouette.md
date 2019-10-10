# AWS Cognito vs Silhouette with auth in Play

## Context
This is about the choice we have for authentication and authorisation within the TDR web app and authentication for other services which carry out processing on the data. 

Cognito is an AWS service which provides authentication and authorisation. 
Silhouette is a Scala library which allows you to add authentication and authorisation to your app.

We originally had the prototype app using Cognito but I believe that it is not suitable for our purposes.

## Issues with Cognito

### Fitness for our use case. 

If you look on the [getting started] page for developers for Cognito, within the first section, the sample apps are all for IOS, Android or Javascript single page apps and I think that this is the main use case for Cognito. 
We found that this means that if you want to sign in using your own UI, you need to use the javascript SDK. Because we are following the principals of progressive enhancement, we can't have our sign in process reliant on javascript being enabled in the browser.
There are examples in there for Java and other server side languages, but these all use the hosted UI.

### The UI
Amazon provide a hosted sign in page, which works without javascript enabled and allows you to use Cognito server side. The problem with this is that there are very few ways of configuring this UI visually. This is how it looks without any extra configuration.
 
![cognito hosted sign in page][sign in]

It looks to me that this is meant for a mobile first app with the large gray space around the sign in box. This can't be changed.
You can customise the sign in box colours, font weights, input box sizes and you can add an image to the banner but the layout and background stay the same. The full choice of options are described [here]

### Configuration
Cognito needs to be configured in AWS. We need to set up user pools, app clients and federated identities.

We need to create and maintain a user and token database to store the jwt tokens Cognito provides.

We need to configure an https certificate and domain name for the hosted UI.

We are using terraform to provision all of our AWS resources and each of these parts adds an extra layer of complexity to the terraform project.
Also, any new developers will need to have an understanding of Cognito, and how to provision Cognito in terraform before they can understand our authentication fully. 

### Developer experience
For new developers, they will need both and understanding of Cognito and understanding of terraform to be able to understand fully how the the auth works.

The auth is spread over three repositories, terraform, the web app (including separate config for the front end javascript and back end codee) and the API. 
Again, this will make it more difficult for new developers and more difficult to maintain for the existing ones.

As this is a hosted service, there is no way to run a local copy of Cognito. 
This means that we need a second app client set up in terraform just for running the app locally and for automated testing and everyone is sharing this client, so changes made to it will affect everyone's local development environment.

### Vendor lock in
Our prototype app is at the moment, reasonably vendor agnostic. 
All of our services are run in docker containers and messages are passed using queues. 
As it is, we could move to another provider. 
If we use Cognito for authentication, this is locking us into AWS and it will be difficult to swap this out for another provider's service.

### Gradated access compatibility
We will need our authentication to be compatible with the as yet unwritten gradated access system. 
Cognito supports connections to [SAML] and [OpenId Connect] providers but no others. If the gradated access project supports neither of these then we will find it difficult to integrate them.

### Other clients
Cognito can be used to authenticate the web app with the API which stores and provides the data. The problem is that the web app is not the only client of the API.
There are backend tasks which process the files and export them at the end of the process and as these run asynchronously and aren't connected to a particular Cognito user, they cannot use Cognito for authentication. 
The way we solved this was to have two endpoints on the API, one using Cognito auth for the web app and one using IAM auth for everything else. 
This adds more configuration to terraform and it means that different services need different API endpoints which adds to the complexity of the app.

### User creation page         
As it is now, users will be created by someone within TNA. For Cognito, this means creating an AWS IAM user, setting the permissions correctly and training them to create and maintain users. 


## Using Silhouette with Play

### Fitness for our use case.
[Silhouette] is a Scala authentication and authorisation library. It is well used and well tested. Because it is integrated with the Play MVC framework, we can easily use this to authenticate a desktop app.

### The UI
There is no hosted UI. This is built into the Play app, the UI can be anything we want it to be.

### Configuration
All of the configuration is done within a single package in the Play app. All of the code is in one place and the core logic is spread over 3 or 4 files. Adding authorisation logic is also simple.

### Developer experience
For new developers, they will need to understand Scala and Play. They will need to understand this anyway to work on TDR so there are no extra skills needed to understand the authentication.

All auth configuration code is located in one repo. There is a layer in the API which saves and retrieves the users as well 

Running a local copy needs no extra configuration from the developer. It will just work.

### Vendor lock in
As this is running as part of the web app which is itself running in a container, we are not restricted to where we run this.

### Gradated access compatibility.
Silhouette has more options for integrating with other [auth providers] In the simplest case, we can simply use a shared user database but other more complex options are available.

### Other clients
Without Cognito, we use IAM roles to authenticate with the API through the Play app. This means that all of the API clients use the same authentication mechanism and removes the need for a separate endpoint and multiple authentication methods.

### User creation page
As with the log in page, we have full control over this so users can be created with no training or extra configuration needed 

## Other considerations

### Authorisation
We need to restrict access to pages within the app to logged in users and we may need to restrict some pages to certain types of users.
Both solutions will need this logic to be written by our developers. When we were using Cognito for authentication, we were still using Silhouette for authorisation.

### Changing our minds
If, in the future, something happens that means we want to integrate Cognito again, we can do it as the Silhouette library supports it, although this would add in all the extra complexity mentioned above.

### Two factor auth and password resets
Cognito provides two factor auth and password resets almost out of the box although these use the same hosted UI as the sign in page.
Silhouette also supports them. There is some development effort involved but there is 2FA and a password reset facility set up on the prototype and this only took a day or two.
   
 
[auth providers]: https://www.silhouette.rocks/docs/config-introduction
[Silhouette]: https://www.silhouette.rocks/
[SAML]: https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-saml-idp.html
[OpenID Connect]: https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-identity-provider.html#cognito-user-pools-oidc-providers
[here]: https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-app-ui-customization.html
[sign in]: images/cognito-sign-in.png
[getting started]: https://aws.amazon.com/cognito/dev-resources/