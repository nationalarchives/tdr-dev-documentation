# Client secret rotation alerts

We have a lambda which rotates the Keycloak client secrets once a week. This will send a message to Slack once it has completed. 

It will list each of the clients and whether they have passed or failed. A fully successful run will look like this:

```
Client tdr-reporting has been rotated successfully
Client tdr-backend-checks has been rotated successfully
Client tdr-realm-admin has been rotated successfully
Client tdr-rotate-secrets has been rotated successfully
Client tdr-user-admin has been rotated successfully
Client tdr rotation has been rotated successfully
```

If any of the clients fail, it will say `Client *** has failed` If this happens, check the Cloudwatch logs for `/aws/lambda/tdr-rotate-secrets-${environment}`