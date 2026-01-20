# TDR Athena Analytics

## Overview

The Metadata Upload feature captures error details in JSON files stored in an S3 bucket. To enable reporting on these errors (e.g. for user experience analysis), we use AWS Athena. This setup allows users to query the data efficiently.

## Athena Setup

The Athena infrastructure is provisioned using Terraform. However, the external table must be created manually once.

1.  Log in to the AWS Console.
2.  Navigate to **Athena**.
3.  Locate the saved query for creating the external table.
4.  Run the query to create the table `metadata_validation_reports`.

## Populating the Data

Currently, the data for the Athena table needs to be populated manually by a developer using a Python script. This script aggregates the individual JSON error files from S3 into a format suitable for Athena and uploads them directly to the destination S3 bucket.

The script is located at: `manual/scripts/populate_athena_metadata.py`

### Prerequisites

*   Python 3 installed on your local machine.
*   AWS credentials (access key and secret key) with permissions to access the relevant S3 buckets (`tdr-draft-metadata-intg` and `athena-tdr-metadata-checks-intg`).

### Running the Script

1.  **Prepare the environment:**
    Ensure you have the `manual/scripts/populate_athena_metadata.py` file.

2.  **Set up a virtual environment:**
    To ensure clean dependencies, create and activate a virtual environment, then install `boto3`.

    ```bash
    python3 -m venv venv
    source venv/bin/activate
    pip install boto3
    ```

3.  **Set Environment Variables:**
    Export your AWS credentials to your local environment variables so the script can authenticate.

    ```bash
    export AWS_ACCESS_KEY_ID="your_access_key"
    export AWS_SECRET_ACCESS_KEY="your_secret_key"
    export AWS_SESSION_TOKEN="your_session_token" # If using temporary credentials
    ```

4.  **Update and Run the Script:**
    *   Review the script to ensure it points to the correct S3 locations if strictly hardcoded (default is `tdr-draft-metadata-intg` -> `athena-tdr-metadata-checks-intg`).
    *   **Check the `MAX_FILES` configuration:** The script includes a `MAX_FILES` variable (defaulting to 50 for testing purposes). You should update this to a higher value (or remove the limit logic) to ensure all relevant files are processed.
    *   Run the script:
        ```bash
        python manual/scripts/populate_athena_metadata.py
        ```
    *   When finished, you can deactivate the virtual environment:
        ```bash
        deactivate
        ```

    *The script will process the files and populate the data source for the `metadata_validation_reports` table by uploading a consolidated file to S3.*

## Accessing Reports

Once the table is populated, authorized users can run SQL queries in Athena to analyze the metadata validation errors.

