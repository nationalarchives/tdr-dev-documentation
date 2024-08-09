## 33. User permissions for DTA Review feature

## Context

Work is underway for the TDR web application to support a new step in the standard transfer journey whereby a TNA Digital Transfer Advisor can review consignment metadata input by a transferring body and either approve (allowing them to proceed with transfer) or reject (requiring metadata changes before the transfer can proceed).

The Digital Transfer Advisor will be able to download metadata associated with a consignment for which a review has been requested in spreadsheet form. When they submit a review decision, it will require an update in the table recording the state of the consignment they are reviewing.

This will require a departure from our existing user permission model, where calls to fetch or amend data in the consignment API can only be successful when using the authorisation token of the user who originally uploaded the data.

There is also an emerging requirement for multiple users alongside the user who ultimately approves or rejects the review to have access to consignment metadata. The ability to download and inspect the metadata under review will need to be extended to a wider group of supporting TNA colleagues as part of the review process.

In the development version of the DTA review feature, a `tna_user` subgroup of the `user_type` keycloak group has been created at the same level as the existing `standard_user` and `judgment_user` types. This user's token grants read and write access on all consignments in the backend.

Frontend actions associated with reviewer facing pages are wrapped in a check on the `tna_user` type for the current user, without which they cannot be performed. These pages have all been created under the /admin path, which IP restricts access to DTA review pages to users on the TNA network.

## Decision

In addition to the above steps taken in the TDR Frontend, we will implement a further level of permissions granularity in the consignment API supported by two additional `tna_user` subgroups: `transfer_adviser` and `metadata_viewer`.

The `metadata_viewer` will have read only permissions on all data associated with consignments _with an in progress review status_.

The `transfer_advisor` will have all the permissions of `metadata_viewer`, and in addition, write permissions on the table recording the status of consignment reviews.

## Other options considered

The path of least resistance (and already implemented in the testing version of the app), is simply to add an 'is TNA user' disjunct to the `ValidateUserHasAccessToConsignment` authorisation tag in the consignment API. This gives a caller with the TNA user token read and write access to all consignments.

We considered whether the IP restrictions on pages under `admin` routes alone would sufficiently mitigate leaving access so open in the backend. It was decided that following a principle of least permissions in the backend in addition would be a preferable route, providing a further guardrail against undesired data exposure from misconfigured frontend controllers.

