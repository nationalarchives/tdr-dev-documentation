# Export performance testing of BagIt export

Date: 2019-11-18

The original [content export investigation](content-export.md) and performance
testing was done while we were still considering options for exporting content
from TDR to the preservation system. Since then, we've investigated [export
format requirements][export-format] and decided to use the [BagIt file
packaging format][BagIt] and export the data to an S3 bucket, so the export
process needs to be retested with large data sets.

[export-format]: TDR&#32;Export&#32;Format&#32;Requirements.md
[BagIt]: https://tools.ietf.org/html/rfc8493

## Export process

The process being tested runs on an AWS ECS container. It runs a container built
from the [tdr-prototype-file-export] project versions fccec80 and 1290c29 (which
includes a small bug fix for large files).

The steps are:

1. Fetch details about the consignment (including original file paths) from the
   TDR API
2. Download the files from S3 to their original file paths
3. Run [bagit-java] to create a BagIt bag containing the files and metadata
4. Create a tar.gz archive file of the bag
5. Upload the tar.gz file to another S3 bucket

[tdr-prototype-file-export]: https://github.com/nationalarchives/tdr-prototype-file-export
[bagit-java]: https://github.com/LibraryOfCongress/bagit-java

## Results

The total time is more than the combined time because it includes other
processes like starting the container and fetching consignment data from the
API.

| Collection           | Download time | BagIt time            | tar.gz time           | S3 upload time | Total time |
| -------------------- | ------------- | --------------------- | --------------------- | -------------- | ---------- |
| 1000 x 10 kB images  | 20 seconds    | 15 seconds            | 4 seconds             | 8 seconds      | 1 min 12 s |
| 10000 x 10 kB images | 5 min 43 s    | **Out of memory**     | -                     | -              | -          |
| 500 x 1.8 MB images  | 1 min 27 s    | 1 min 6 s             | 2 min 49 s            | 1 min 2 s      | 7 min 36 s |
| 10 x 610 MB wavs     | 4 min 30 s    | **Out of disk space** | -                     | -              | -          |
| 1 x 1.6 GB file      | 2 min 7 s     | 1 min 19 s            | 4 min 1 s             | 2 min 24 s     | 9 min 33 s |
| 1 x 5.4 GB file      | 6 min 59 s    | 4 min 22 s            | **Out of disk space** | -              | -          |

The consignments which succeeded all took less than 10 minutes, which is fine.
The export time only affects how quickly an archivist can access the data when a
user has confirmed the transfer.

The 10000 file consignment ran out of memory during the BagIt step. We should
investigate this is in Beta to try to find out why BagIt is using so much
memory, whether we can fix it, or whether we should allocate more memory to the
ECS container.

The consignments with large files ran out of disk space during the BagIt or
tar.gz step because they reached the [10 GB limit on
Fargate][fargate-disk-limit]. We should look into batching exports in Beta. This
may be tricky for large individual files, and we may have to use BagIt's
[fetch.txt][bagit-fetch] to reference large files.

[fargate-disk-limit]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-task-storage.html
[bagit-fetch]: https://tools.ietf.org/html/rfc8493#section-2.2.3
