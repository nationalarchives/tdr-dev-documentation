# Deploy the service unavailable page. 

There is now a service unavailable page which can be deployed. Users will see this page instead of the main TDR app. This could be used when there is a serious issue with TDR that we can't fix immediately or if there is service affecting maintenance we need to do.

## Switch to the service unavailable page

There is a [GitHub actions job] to deploy the page.  

Choose the environment you want to deploy it to and select `ServiceUnavailable` in the `service-to-deploy` parameter.

## Switch back to the TDR app.

The same [GitHub actions job] will restore the TDR app. Select the environment you want to restore and select `TDRApp` in the `service-to-deploy` parameter. 

[GitHub actions job]: https://github.com/nationalarchives/tdr-service-unavailable/actions/workflows/run.yml 
