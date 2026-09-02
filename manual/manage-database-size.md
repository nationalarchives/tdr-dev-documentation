# Manage database size (for capacity testing on staging)

The capacity tests which run on staging every night mean that over time the database becomes quite large and the tests start to fail.
To keep things realistic we periodically delete older records in order to keep the database around 1-3 times that seen on production.

With the volume of tests we are running in August 2026 this clean up needs to ne run every 2-3 weeks.   We connect to the staging database from cloudshell, using the ```migrations_user```.

## Recording the size of the database before and after clean up 

A record of the sizes before and after clean up is kept in an excel file (database-sizes.xlsx), a link to this can be found on this confluence page: https://national-archives.atlassian.net/wiki/spaces/DA/pages/1884749826/Capacity+2026-27+DRAFT+WIP+NOTES.  That page also has a link to the spreadsheet (overnight-tests.xlsx) in which we record the outcome of each evening's run of the capacity tests.


We use the number of records in the largest table (FileMetadata) as the guide to daatabse size:

```  
select count(*) from "FileMetadata";
```  

We record that number as well as the total size of the table in MB, which we find with:
```
select table_name, pg_size_pretty(pg_total_relation_size(quote_ident(table_name))), pg_total_relation_size(quote_ident(table_name))
from information_schema.tables
where table_schema = 'public'
order by 3 desc;```
```
We also record the total size of the whole database in GB.  We find that with:

```
select pg_size_pretty(pg_database_size(current_database())), pg_database_size(current_database());
```

## Deciding the date to delete records before

We will delete all records before a certain date.  We pick that date based on the number of records in the FileMetadata table.  The target is to keep the number of records in that table between 1 and 3 times the number seen on production.

Find a date that will leave us with a count of records in FileMetadata that is around the same number seen on production (typically around 10 days ago).  We can do this by running the following query:

```
select count(*) from "FileMetadata" where "FileId" in (select "FileId" from "File" where "Datetime" >= 'YYYY-MM-DD');
```

## Deleting the records

Once the date has been selected we can delete the records.  We do this by running the following query (with the date replaced by the date you have chosen):

```
DO $$
DECLARE
  date_before DATE := 'YYYY-MM-DD'; -- replace with the date you have chosen
BEGIN
  delete from "AVMetadata" where "FileId" in (select "FileId" from "File" where "ConsignmentId" in (select "ConsignmentId" from "Consignment" where "Datetime" < date_before));
  delete from "FFIDMetadataMatches" where "FFIDMetadataId" in (select "FFIDMetadataId" from "FFIDMetadata" where "FileId" in (select "FileId" from "File" where "ConsignmentId" in (select "ConsignmentId" from "Consignment" where "Datetime" < date_before)));
  delete from "FFIDMetadata" where "FileId" in (select "FileId" from "File" where "ConsignmentId" in (select "ConsignmentId" from "Consignment" where "Datetime" < date_before));
  delete from "FileMetadata" where "FileId" in (select "FileId" from "File" where "ConsignmentId" in (select "ConsignmentId" from "Consignment" where "Datetime" < date_before));
  delete from "FileStatus" where "FileId" in (select "FileId" from "File" where "ConsignmentId" in (select "ConsignmentId" from "Consignment" where "Datetime" < date_before));
  delete from "File" where "ConsignmentId" in (select "ConsignmentId" from "Consignment" where "Datetime" < date_before);
  delete from "ConsignmentStatus" where "ConsignmentId" in (select "ConsignmentId" from "Consignment" where "Datetime" < date_before);
  delete from "ConsignmentMetadata" where "ConsignmentId" in (select "ConsignmentId" from "Consignment" where "Datetime" < date_before);
  delete from "MetadataReviewLog" where "ConsignmentId" in (select "ConsignmentId" from "Consignment" where "Datetime" < date_before);
  delete from "Consignment" where "Datetime" < date_before;
END $$;
```

As a final step we run vacuum and analyze on each of the tables:

```
VACUUM ANALYZE "AVMetadata";  
VACUUM ANALYZE "FFIDMetadataMatches"; 
VACUUM ANALYZE "FFIDMetadata";  
VACUUM ANALYZE "FileMetadata";  
VACUUM ANALYZE "FileStatus";  
VACUUM ANALYZE "File";  
VACUUM ANALYZE "ConsignmentStatus"; 
VACUUM ANALYZE "ConsignmentMetadata"; 
VACUUM ANALYZE "MetadataReviewLog"; 
VACUUM ANALYZE "Consignment";  
```

Note that the vacuum command does not reclaim the space used by the deleted records, but it does make that space available for re-use by new records.  The analyze command updates the statistics used by the query planner to determine the most efficient way to execute queries.  
Previously we have run VACUUM FULL, which does reclaim the space, but for now experimenting to see if the FULL is not needed or was counter-productive. 


## After the clean up 

Record the new sizes of the FileMetadata table and the database in the spreadsheet (database-sizes.xlsx).