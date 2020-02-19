## Silhouette vs pac4j

We needed a library to integrate with Keycloak to provide authentication and authorisation in the frontend Play app.

Our two potential choices were [Silhouette](https://www.silhouette.rocks/) and [pac4j](https://www.pac4j.org/) 

The main criteria we used to decide between them were the following:

* Scala or Java - This is mostly down to the fact that integrating Java libraries into a Scala project can make the code more verbose although this is a minor concern.
* Ease of testing - What libraries are provided for testing
* Ease of switching providers - How easy it is to swap out keycloak for another OIDC provider
* Native OIDC support - Does the library support OIDC out of the box. If it doesn't, then we have to write our own controllers and the less custom code written for authentication, the better.

| Criteria                      | Silhouette                                                                                                                                                          | Pac4j                                                                                                                                                             |
|------------------------------ | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------| :-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Scala or Java                 | Scala                                                                                                                                                               | Java                                                                                                                                                              |
| Ease of testing               | There is a [testing library](https://www.silhouette.rocks/docs/testing) available to make it easy to test.                                                          | There is no testing library. It is possible to test though using mocks and this has been done.                                                                    |
| Native OIDC support           | No                                                                                                                                                                  | Yes                                                                                                                                                               |
| Ease of switching providers   | Easy - Once it is configured, it should be a case of swapping out the endpoints for the new provider but as there is more custom code involved, this is not certain | Very easy - The configuration is all done from the OIDC configuration endpoint so it would be a case of pointing one application property to a new auth provider. |

Based on these criteria, we decided to use pac4j. Although it is a Java library, the more verbose Java style code is limited to the configuration file. The testing is more difficult but once it's set up, there's very little extra work needed. The main advantage is that all of the controllers for the authentication endpoints are auto generated which cuts down on the amount of custom code needed and makes it very easy to switch provider if we need to.


