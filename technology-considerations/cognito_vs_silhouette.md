# AWS Cognito vs Silhouette with auth in Play

## Context
This is about the choice we have for authentication and authorisation within the TDR web app and authentication for other services which carry out processing on the data. 

Cognito is an AWS service which provides authentication and authorisation. 
Silhouette is a Scala library which allows you to add authentication and authorisation to a Play MVC app. 

Our first prototype was a single page application using Cognito for authorisation. For a single page app, Cognito is a good choice. We can use the full featured javascript API to sign in, all of the tokens are stored in cookies and in local storage within the browser and all calls are made out to API gateway directly from the front end.
 The [getting started] page for Cognito lists sample apps for IOS, Android and an Angular single page app which suggests that these are the main use cases for Cognito.

Our second prototype however is no longer a single page app. We are following the GDS recommended strategy of progressive enhancement which means that the site needs to work without javascript wherever possible and this includes the sign in functionality. We also have back end processing tasks communicating with the API which weren't present in the original prototype which have no concept of a user and so can't use Cognito for authentication.

The below table lists some comparisons between the two approaches. They're based around three rough criteria: 
* How easy it is to integrate with other services, either the gradated access service or another cloud provider.
* How easy it is to develop and maintain. 
* How usable is it. 


| Criteria      | Cognito           | Silhouette  |
| ------------- |:-----------------|:------------|
| Vendor lock in| Our prototype app is at the moment, reasonably vendor agnostic. <br>All of our services are run in docker containers and messages are passed using queues. <br> As it is, we could move to another provider. If we use Cognito for authentication, this is locking us into AWS and it will be difficult to swap this out for another provider's service.|As this is running as part of the web app which is itself running in a container, we are not restricted to where we run this.|
| Gradated access compatibility | We will need our authentication to be compatible with the as yet unwritten gradated access system. <br>Cognito supports connections to [SAML] and [OpenId Connect] providers but no others. If the gradated access project supports neither of these then we will find it difficult to integrate them. | Whichever form the gradated access service takes, having full control over our authentication layer will allow us to integrate with this.
| The UI        | Amazon provide a hosted [sign in] page, which works without javascript enabled and allows you to use Cognito server side. The problem with this is that there are very few ways of configuring this UI visually. <br> The design suggests that this was designed for a mobile first app with the large gray space around the sign in box. This can't be changed. You can customise the sign in box colours, font weights, input box sizes and you can add an image to the banner but the layout and background stay the same. The full choice of options are described [here] | There is no hosted UI. This is built into the Play app, the UI can be anything we want it to be. We can use the GDS design system, TNA's design system or a mixture of the two. | 
| Configuration | Cognito needs to be configured in AWS. We need to set up <ul><li>User pools</li><li>App clients</li><li>Federated identities</li><li>Database storage for users</li><li>Database storage for tokens</li><li>Certificates for hosted UI</li></ul> | All of the configuration is done within a single package in the Play app. All of the code is in one place and the core logic is spread over 3 files. Authorisation logic can be added using Silhouette's built in mechanisms. | 
| Developer Experience | For new developers, they will need both and understanding of Cognito and understanding of terraform to be able to understand fully how the the auth works as well as the standard Scala and Play skills. <br><br> The auth is spread over three repositories, terraform, the web app (including separate config for the front end javascript and back end code) and the API. This will make it more difficult for new developers and more difficult to maintain for the existing ones. <br><br>  As this is a hosted service, there is no way to run a local copy of Cognito. <br> This means that we need a second app client set up in terraform just for running the app locally and for automated testing and everyone is sharing this client, so changes made to it will affect everyone's local development environment. | For new developers, they will need to understand Scala and Play. They will need to understand this anyway to work on TDR so there are no extra skills needed to understand the authentication.<br><br> All auth configuration code is located in one repo. There is a layer in the API which saves and retrieves the users as well <br><br> Running a local copy needs no extra configuration from the developer. It will just work. |
| Maintainability | Because of the reasons listed above, it is likely that more time will need to be spent maintaining this which means developers have less time to develop new features. The extra complexity also means there is a greater chance of bugs being introduced in the authentication layer which in the worse case could lead to someone gaining access to the app who shouldn't. | As the auth code is all inside one package in one repository and all written in a single language (Scala), this will be easier to maintain. |
| Other Clients | Cognito can be used to authenticate the web app with the API which stores and provides the data. However, the web app is not the only client of the API. <br> There are backend tasks which process the files and export them at the end of the process and as these run asynchronously and aren't connected to a particular Cognito user, they cannot use Cognito for authentication. <br> The way we solved this was to have two endpoints on the API, one using Cognito auth for the web app and one using IAM auth for everything else. <br> This adds more configuration to terraform and it means that different services need different API endpoints which adds to the complexity of the app.  | Without Cognito, we use IAM roles to authenticate with the API through the Play app. This means that all of the API clients use the same authentication mechanism and removes the need for a separate endpoint and multiple authentication methods. |
| User Creation | To create users for Cognito, an AWS IAM user needs to be created, the permissions need to be set correctly and potentially inserts will need to be done into a user database. This will require training for the people creating the users and the extra complexity in the process means that maintaining existing users will take more time. | As with the log in page, we have full control over this so users can be created with no training or extra configuration needed |
| Authorisation | We need to restrict access to pages within the app to logged in users and we may need to restrict some pages to certain types of users. <br> This logic to be written by our developers. When we were using Cognito for authentication, we were still using Silhouette for authorisation. | We can use Silhouette again for authorisation which means that our authentication and authorisation are all contained within a single library, reducing setup time and maintenance costs.
| Changing our minds | In order to re-integrate Cognito with the app, we will need to re-introduce all of the terraform configuration and all of the workarounds we needed in order to integrate Cognito with our application.| Silhouette supports Cognito integration so we could change back to Cognito without changing libraries, although we would still need to introduce all the extra configuration and complexity  |
| 2FA and Password Resets | Cognito provides support for this out of the box although this uses the same hosted UI as the sign in page. | We need to write code for 2FA and password resets but this is well supported in Silhouette and won't take too long to implement. It has already been added to the prototype. | 


[auth providers]: https://www.silhouette.rocks/docs/config-introduction
[Silhouette]: https://www.silhouette.rocks/
[SAML]: https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-saml-idp.html
[OpenID Connect]: https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-identity-provider.html#cognito-user-pools-oidc-providers
[here]: https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-app-ui-customization.html
[sign in]: images/cognito-sign-in.png
[getting started]: https://aws.amazon.com/cognito/dev-resources/