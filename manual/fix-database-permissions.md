# Fix database permissions errors

Sometimes, the database user for the consignment API doesn't get granted permissions for new tables.

This should never happen under normal conditions as the user should have permissions for all new tables.

If it does happen, you need to grant access to all tables for the Consignment API user.

## Steps
* Create a bastion for the environment you need.
* Connect to the database using the admin credentials. These can be found in the parameter store
  * url = /{environment}/consignmentapi/database/url
  * username = /{environment}/consignmentapi/database/username
  * password = /{environment}/consignmentapi/database/password
* Log onto the bastion and run `psql -h {url} -U {username} -d consignmentapi` and enter the password when prompted.
* Run the following commands

```
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO consignment_api_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO consignment_api_user
```