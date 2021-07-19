# Deploy the service unavailable page. 

There is now a service unavailable page which can be deployed. Users will see this page instead of the main TDR app. This could be used when there is a serious issue with TDR that we can't fix immediately or if there is service affecting maintenance we need to do.

## Switch to the service unavailable page

There is a [Jenkins job] to deploy the page.  

Choose the environment you want to deploy it to and select `ServiceUnavailable` in the `SERVICE_TO_DEPLOY` parameter.

## Switch back to the TDR app.

The same [Jenkins job] will restore the TDR app. Select the environment you want to restore and select `TDRApp` in the `SERVICE_TO_DEPLOY` parameter. 

[Jenkins job]: https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Service%20Unavailable%20Run/build 
