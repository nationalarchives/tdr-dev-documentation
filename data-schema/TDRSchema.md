# TDR Database Schema

To support the proposed TDR database schema design a series of scripts have been created
to aid with the initial setup.

## TDR Schema Creation

The TDRSchemaCreation.sql file contains the sql statement to create the database schema as proposed in the design documentation.
The script is written in a PostgreSql style since this is believed to be the format preferred within the project team.

## Body Data

The Body_Insert.sql file contains an insert statement to create example data within the Body table of the schema.
The data included is intended as an example and does not pretend to be a full list of the Government organisations.
Whilst we were able to obtain a full list of these organisations, over 950, we were not able to completely match these with
the bodies and therefore Series contained within the DRI. 
We therefore decided to use the Bodies and related Series held within the DRI to create the initial data.

## Series Data
The Series_Insert.sql script creates example Series data, and associated Bodies, within the Series table. 
The data for the series came from the current DRI and is not intended to be a full list of Series, of which there is over 20K, 
as described by the catalogue team.