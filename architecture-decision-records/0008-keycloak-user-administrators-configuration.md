# 8. Keycloak User Administrators Configuration

**Date:** 2020-06-17

This decision has been superseded by decision: [0009 Keycloak User Administrator Configuration](0009-keycloak-user-administrators-configuration.md) 

## Context

Keycloak provides a flexible way to organise access for users to its administration functions.

TDR requires user configuration that allows the following:
* Set of users permission to manage transferring body users, ie the users of the TDR application.
* Set of users permission to manage keycloak users, ie those internal TNA users who can administer Keycloak itself, including setting up TDR application users.

The configuration needs to consider the following principles:
* *Least privilege*: only allow the user the minimum level of permissions to perform the requires operations
* *Elevated privileges*: prevent a user accruing additional permissions above what they require
* *User data protection*: ensure user data is secure

## Options considered

### Option 1: Define user administrators in the top level realm and TDR realms

The transferring body user administrators will be defined in the TDR realm, with the "super" user administrators defined in the top level realm

* **Top Level Realm**
  * *super_user_administrator* group:   
    * Access to all users/groups within the top level realm only    
    * Has access to self 
* **TDR Realm**
  * *user_administrator* group:  
    * Access to all users/groups within the tdr-realm only    
    * Access to self
  * *transferring_body_user* group: 
    * Access to TDR application only
    * Access to series belonging to transferring body

With this configuration the transferring body user administrators and super user administrators can give themselves limited elevated privileges.

### Option 2: Define TDR user administrators in top level realm

Both transferring body user administrators and "super" user administrators will be defined in the top level realm

* **Top Level Realm**
  * *super_user_administrator* group:   
    * Access to all users/groups within the top level realm only (this includes the *tdr_user_administrator* as this is held within the top level realm)    
    * Has access to self    
  * *tdr_user_administrator* group:  
    * Access to all users/groups within the TDR realm only    
    * No access to self  
* **TDR Realm**
  * *transferring_body_user* group: 
    * Access to TDR application
    * Access to series belonging to transferring body

With this configuration the super user administrators can give themselves limited elevated privileges.

## Decision

Decided on Option 2. 

Having user administrators in the top level realm provides a clear demarcation between transferring body users which will be defined in the TDR realm users. 

This provides additional protection against inadvertently giving incorrect permissions to transferring body users.

## TDR User Administrators Configuration

User administrators will be users that have permission to manage other users. 

This will include transferring body users and internal TNA users.

"Groups" will be used to define the permissions. This will allow easier administration of the permissions, as the permission will be defined by the group and keycloak users can be added or removed to the groups.

## Keycloak User Configuration Background

### Realms

Keycloak user the concept of "realms".

A realm manages a set of users, credentials, roles, and groups. A user belongs to and logs into a realm. 

Realms are isolated from one another and can only manage and authenticate the users that they control.

#### Top Level Realm

Keycloak comes with a pre-defined "top level" realm which is at the highest level in the hierarchy of realms. 

Admin accounts in this realm have permissions to view and manage any other realm created on the server instance. 

Keycloak recommends that the top level realm is not used to manage users and applications, and should be reserved for super admins to create and manage the realms in the system.

### Roles

Roles identify a type or category of user. 

Used to apply specific permissions to individual users.

### Groups

Groups in Keycloak allow management of a common set of attributes and role mappings for a set of users. 

Users can be members of zero or more groups. Users inherit the attributes and role mappings assigned to each group.

## Useful Documents

* Keycloak documentation: https://www.keycloak.org/docs/latest/server_admin/