import boto3
import json
import sys
from datetime import datetime

# Configuration
SOURCE_BUCKET = "tdr-draft-metadata-intg"
DEST_BUCKET = "athena-tdr-metadata-checks-intg"
DEST_PREFIX = "metadata-validation-reports/"
FILE_PATTERN = "draft-metadata-errors.json"
MAX_FILES = 50

def main():
    # Initialize S3 client
    s3 = boto3.client('s3')

    print(f"Scanning bucket '{SOURCE_BUCKET}' for '{FILE_PATTERN}' (including all versions)...")

    try:
        # Paginator to handle large number of object versions
        paginator = s3.get_paginator('list_object_versions')
        pages = paginator.paginate(Bucket=SOURCE_BUCKET)
    except Exception as e:
        print(f"Error accessing source bucket: {e}")
        sys.exit(1)

    candidates_by_key = {}
    total_versions_found = 0
    stop_scanning = False
    last_processed_key = None

    for page in pages:
        if stop_scanning:
            break

        # 'Versions' contains the actual object versions
        if 'Versions' in page:
            for version in page['Versions']:
                key = version['Key']

                # Check if file matches the specific filename we are looking for
                if key.endswith(f"/{FILE_PATTERN}") or key == FILE_PATTERN:
                    # If we switched to a new key and have enough files, stop scanning
                    # This ensures we don't stop in the middle of a key's versions (getting only newest ones)
                    if last_processed_key is not None and key != last_processed_key:
                        if total_versions_found >= MAX_FILES:
                            stop_scanning = True
                            break

                    if key not in candidates_by_key:
                        candidates_by_key[key] = []

                    candidates_by_key[key].append(version)
                    total_versions_found += 1
                    last_processed_key = key

    output_buffer = []
    count = 0

    print(f"Found {total_versions_found} versions across {len(candidates_by_key)} unique files. Processing...")

    for key, versions in candidates_by_key.items():
        # Sort versions by LastModified (oldest first) to number them 1..N
        versions.sort(key=lambda x: x['LastModified'])

        for idx, version in enumerate(versions, start=1):
            version_id = version['VersionId']

            try:
                print(f"Processing: {key} (Version: {version_id}) -> Index {idx}")

                # Get the specific version of the object
                response = s3.get_object(
                    Bucket=SOURCE_BUCKET,
                    Key=key,
                    VersionId=version_id
                )

                # Read and decode content
                content = response['Body'].read().decode('utf-8')

                if not content.strip():
                    continue

                # Parse JSON to ensure it is valid and to format it
                json_content = json.loads(content)

                # Inject the sequential index as version ID (1 = oldest)
                json_content['s3VersionId'] = str(idx)

                # Convert back to a single-line string (compact JSON)
                compact_json = json.dumps(json_content)
                output_buffer.append(compact_json)
                count += 1

            except json.JSONDecodeError:
                print(f"Warning: Invalid JSON in {key} (v: {version_id}), skipping.")
            except Exception as e:
                print(f"Error processing {key} (v: {version_id}): {str(e)}")

    if count == 0:
        print("No matching files found.")
        return

    # Join all JSON lines with newlines (NDJSON format)
    final_content = "\n".join(output_buffer)

    # Generate a unique filename for the output
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    output_key = f"{DEST_PREFIX}consolidated_errors_{timestamp}.json"

    print(f"Uploading {count} records to s3://{DEST_BUCKET}/{output_key}...")

    try:
        s3.put_object(
            Bucket=DEST_BUCKET,
            Key=output_key,
            Body=final_content,
            ContentType='application/x-ndjson'
        )
        print("Upload complete.")
    except Exception as e:
        print(f"Error uploading to destination: {e}")

if __name__ == "__main__":
    main()

