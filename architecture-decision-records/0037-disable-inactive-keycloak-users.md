# 37. Disable inactive Keycloak users

**Date**: 2025-02-17

## Context
TDR needs a reliable mechanism to identify and disable users who have not been active within the system for a specified period. Two main approaches were considered:
1. Using Keycloak events to track user activity
2. Directly querying the TDR application database for user activity and cross-referencing with Keycloak

The system needs to ensure that inactive users are properly disabled for security and resource management purposes.

## Decision
Implement a user deactivation strategy based on querying application database for user activity and cross-referencing with Keycloak rather than relying solely on Keycloak events. The approach will:

1. Query the TDR application database to identify users who have been active for a specified period (x days)
2. Compare this data with the Keycloak database
3. Disable inactive users using the Keycloak api

#### Note
- Need to consider the scenario of a user who has never done a transfer. There would be no record of such a user in the TDR application database. When you compare the list with Keycloak, that user would not be disabled.

## Rationale

### Advantages
- More reliable tracking of actual user activity within the TDR application
- Not dependent on Keycloak event logging configuration or retention
- Direct control over the definition of "user activity" based on TDR application's specific needs
- Can retroactively identify inactive users even if Keycloak event logging was not properly configured
- TDR application database already retains user activity such as 'transferInitiatedDateTime' 

### Disadvantages
- Requires regular database queries which may impact performance
- Need to maintain synchronization between TDR application and Keycloak databases
- Will miss user activity that occurs in a non-TDR application that shares the Keycloak instance, for example AYR

## Implementation Notes
- Logic will run via a Lambda
- Will need to create a scheduled job to run the lambda
- The specific threshold for user inactivity (x days) should be configurable
- Consider users that have been created but not logged into the system before
