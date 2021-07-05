# How to add new series

This is currently a manual process for MVP.

This is a stepping stone towards creating a background task which lets a developer update the series table in the database.

The final step will be an admin UI that lets admins add new series themselves.

## Get the series reference

Get the series reference from Claire Driver.

Claire will be talking to cataloguing about each series so will know what the series reference should be.

## Get Transferring Body details

If it is a new transferring body that has not done a transfer through TDR before, then its details need to decided on.

These include:
* Transferring body name
* Transferring body TDR code

This should be discussed with the TDR team initially.

## Create database migration script

The series IDs are not sensitive, so it is OK for them to appear in the [tdr-consignment-api-data] repository.

1. Create a new sql migration file in the `tdr-consignment-api-data` repository to add the new series. See the [adding a migration script] instructions.

2. If the transferring body has not been added to the `Body` table, include a script in the new sql migration file to add it to the table:
   ```
    INSERT INTO "Body" ("BodyId", "Name", "Description", "TdrCode") VALUES
      (uuid_generate_v4(), '[body_id]', '[body_name]', '[tdr_cde]') RETURNING "BodyId" INTO bodyUuid;
   ```
   * `[body_id`]: the id for the new transferring body, eg "Ministry of Justice"
   * `[body_name]`: the name of the new transferring body, eg "Ministry of Justice"
   * `[tdr_code]`: the code that is used ***internally by the TDR product***. Should be prefixed by "TDR-", eg: "TDR-MOJ"
      
   **Note:** The transferring body needs to exist in the `Body` table before the new series can be added to the `Series` table.
   
3. Include a script in the new sql migration file adding the new series to the `Series` table:   
   ```
    INSERT INTO "Series" ("SeriesId", "BodyId", "Code", "Name", "Description") VALUES
      (uuid_generate_v4(), [body_uuid], '[series_code]', '[series_name]', '[series_description]');
   ```
   * `[body_uuid]`: this is the value from the `BodyId` column in the `Body` table for the transferring body
   * `[series_code]`: this is the series reference value, eg "LCO 72"
   * `[series_name]`: this is the series reference value, eg "LCO 72"
   * `[series_description]`: this is the series reference value, eg "LCO 72"
   
4. Once the necessary scripts have been added to the new sql migration file follow the [migration deployment] instructions to deploy the changes to the database.
    
## Add new transferring body to Keycloak

If the transferring body is new, and has not done a transfer through TDR, then it will need to be added to Keycloak.

Follow the instructions for adding a [new transferring body to Keycloak].

This change should be deployed to all the TDR environments: integration, staging and production.

The changes should be manually tested in integration first, then staging, before final deployment to production.

[tdr-consignment-api-data]: https://github.com/nationalarchives/tdr-consignment-api-data
[adding a migration script]: https://github.com/nationalarchives/tdr-consignment-api-data#adding-a-migration-script
[migration deployment]: https://github.com/nationalarchives/tdr-consignment-api-data#deployment
[new transferring body to Keycloak]: https://github.com/nationalarchives/tdr-dev-documentation/blob/master/tdr-admins/tdr-user-administrator.md#adding-a-new-transferring-body
