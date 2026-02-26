# TDR Athena Analytics

## Querying metadata errors with Athena 

The Metadata Upload feature captures error details in JSON files stored in an S3 bucket. To enable reporting on these errors (e.g. for user experience analysis), AWS Athena can be used. Athena workgroup and database need to be setup and example tables and data provided.

## Athena Setup

The Athena infrastructure is provisioned using Terraform. However, the external table must be created manually once.

1.  Log in to the AWS Console.
2.  Navigate to **Athena**.
3.  Select ```Query your data in Athena console```
4.  Select Workgroup: ```tdr_reporting_analytics```
5.  Locate and run the saved query for creating the external table ```tdr_reporting_analytics-metadata_validation_reports```

## Populating the Data

Currently, the data for the Athena table needs to be populated manually by a developer using a Python script. This script aggregates the individual JSON error files from S3 into a format suitable for Athena and uploads them directly to the destination S3 bucket.

**Note:** This is an initial 'spiked' approach to setting up the data. Once requirements have been finalized, the population of this data may be automated to require no manual steps.

The script is located at: `manual/scripts/populate_athena_metadata.py`

### Running the Script

1.  **Prepare the environment:**
    Ensure you have the `manual/scripts/populate_athena_metadata.py` file.

2.  **Update and Run the Script:**
    *   Review the script to ensure it points to the correct S3 locations if strictly hardcoded (default is `tdr-draft-metadata-intg` -> `athena-tdr-metadata-checks-intg`).
    *   **Check the `MAX_FILES` configuration:** The script includes a `MAX_FILES` variable (defaulting to 50 for testing purposes). You should update this to a higher value (or remove the limit logic) to ensure all relevant files are processed.
    *   Upload file to cloudshell (cloudshell -> actions -> upload file)
    *   **Clear previous data:** Ensure that any existing consolidated error files (e.g., `consolidated_errors_*.json`) in the destination S3 bucket are deleted. This prevents data duplication in Athena, as the script generates a new file with a timestamp each time.
    *   Run the script from cloudshell:
        ```bash
        python /home/cloudshell-user/populate_athena_metadata.py
        ```
    *The script will process the files and populate the data source for the `metadata_validation_reports` table by uploading a consolidated file to S3.*

## Accessing Reports

Once the table is populated, authorized users can run SQL queries in Athena to analyze the metadata validation errors.
### Example Query

```sql
WITH MultiVersionConsignments AS (
    SELECT consignmentId
    FROM metadata_validgation_reports
    GROUP BY consignmentId
    HAVING COUNT(DISTINCT s3VersionId) > 1
)
SELECT
  m.s3VersionId,
  m.consignmentId,
  v.assetId          AS asset_id,
  e.property         AS property,
  e.message          AS message
FROM metadata_validation_reports m
-- Inner join acts as a filter, keeping only rows where consignmentId exists in the CTE
JOIN MultiVersionConsignments c ON m.consignmentId = c.consignmentId
CROSS JOIN UNNEST(m.validationErrors) AS t (v)
CROSS JOIN UNNEST(v.errors) AS u (e)
WHERE e.message IS NOT NULL
ORDER BY m.consignmentId, m.s3VersionId;
```
