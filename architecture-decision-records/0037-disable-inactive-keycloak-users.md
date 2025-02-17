# 37. Disable inactive keycloak users

**Date**: 2025-02-17

## Context
We need a reliable mechanism to identify and disable users who have not logged in for x about of days. Two main approaches were considered:
1. Using Keycloak events to track user activity
2. Directly querying application database for user activity and cross-referencing with Keycloak

The system needs to ensure that inactive users are properly disabled for security and resource management purposes.

## Decision
We will implement a user deactivation strategy based on querying application database for user activity and cross-referencing with Keycloak rather than relying on solely on Keycloak events. The approach will:

1. Query the application database to identify users who haven't been active for a specified period (x days)
2. Compare this data with the Keycloak database
3. Disable inactive users using the keycloak api

## Rationale

### Advantages
- More reliable tracking of actual user activity in our application
- Not dependent on Keycloak event logging configuration or retention
- Direct control over the definition of "user activity" based on our application's specific needs
- Can retroactively identify inactive users even if event logging was not properly configured
- System database already retains user activity such as 'transferInitiatedDateTime' 

### Disadvantages
- Requires regular database queries which may impact performance
- Need to maintain synchronization between application and Keycloak databases
- May miss user activity that occurs only in Keycloak and not in our application

## Implementation Notes
- Logic will run via a Lambda
- Will need to create a scheduled job to run the lambda
- The specific threshold for user inactivity (x days) should be configurable
- consider users that have been created but not logged into the system before
