# 9. Keycloak User Administrators Configuration

**Date:** 2020-07-21

This decision supersedes decision: [0008 Keycloak User Administrator Configuration](0008-keycloak-user-administrators-configuration.md)

## Context

It was decided to configure the TDR user administrators in the top-level realm in Keycloak: [0008 Keycloak User Administrator Configuration](0008-keycloak-user-administrators-configuration.md)

Whilst implementing the configuration in this way it was found the only way to import the top-level realm json configuration wiped any existing users, at docker container start up.

The decision to configure TDR user administrators in the Keycloak top-level realm was re-considered as a consequence of this issue.

## Decision

Following further investigation and discussion it was decided to take the following approach to avoid any configuration in the Keycloak top-level realm:
1. TDR user administrators are to be configured in the TDR realm instead of the top-level Keycloak realm.
2. A Keycloak group will be set up in the TDR realm with the necessary role mappings to provide the required permissions to administer transferring body users.
3. Logging and alerting will be implemented to notify of any users added to the TDR user administrator group, to mitigate against the risk of elevated privileges abuses.

This approach balances the needs of ensuring Keycloak remains secure, whilst still allowing for ease of maintenance, and extension in the future.

Other options that were considered are outlined below.

## Other Options Considered

### Keeping TDR User Administrator Configuration in the Top Level Realm
Set up the necessary configuration in the top-level realm manually across all TDR environments. 

Some form of automated checking would be implemented to ensure all TDR environments were configured correctly.

#### Issues
* Does not allow for "configuration as code"

### Use Role Mapping Via Users in TDR Realm to Configure TDR User Administrators
Set up user administrators in the TDR realm, and apply the necessary permissions directly to individual users.

#### Issues
* Would need to set the correct user administrator permissions per user, instead of just adding the user to a group. Would mean additional admin burden, and potential for mistakes to be made in applying the permissions.

### Use "Fine Grained" Permissions to configure the Permissions for TDR User Administrators
Keycloak feature that allows configuration for very specific permissions to be granted to users/groups within a single realm, through the setting of policies. 

Permissions can be controlled at a lower level than the broader standard role mappings approach.

See here for further details: https://www.keycloak.org/docs/latest/server_admin/#_fine_grain_permissions

#### Issues
* A "preview" feature in Keycloak, and not fully supported;
* Complex to set up and maintain. Potential to configure incorrectly;
* Unable to give permission for creating a group, which is necessary for the management of the transferring bodies. Would have to give full user administrator permissions to do this, which would effectively negate all the fine-grained permissions.
  
  **Note**: unclear whether this is a bug with the feature, or intentional
 