# Content export investigation

Date: 2019-08-06

## Summary

- We plan to export content from TDR to the preservation system by running a
  background task which zips and encrypts the files, and sends them to an
  existing SFTP server in The National Archives
- We've done some basic performance testing with a
  [prototype][tdr-prototype-file-export], but need to do more, e.g.
  - test with larger files
  - call the TDR API to get the original filenames, instead of using the UUIDs
    used in the S3 bucket
- We expect to have to do some work on the script which downloads files from the
  SFTP server to the preservation system. This script will be quite simple so we
  don't expect it to be difficult to implement, but it's worth noting because it
  will be deployed to an internal system rather than AWS like the rests of TDR.
- The simplest version of the export system (for the first iteration of TDR)
  will support transfers of **up to 10 GB** because of AWS Fargate limits. We
  can support larger transfers in later iterations of TDR by adding a process to
  batch exports.

[tdr-prototype-file-export]: https://github.com/nationalarchives/tdr-prototype-file-export
[loader]: https://github.com/digital-preservation/dali

## Context

Once a user has uploaded files to the Transfer Digital Records application and
confirmed that the upload is ready to be transferred, a digital archivist user
needs to be able to export a Submission Information Package (SIP) so that the
files can be preserved in the archive. The SIP is composed of the content itself
(the files uploaded by the user) and some other files describing the metadata.

TNA already has a system which ingests and preserves SIP data, so the goal for
TDR is to **get a SIP onto the Loader machine** in the format expected by one of
the existing ingest processes. Once it's on the Loader machine, the data is
available to be copied to other parts of the preservation system but this is
outside of the remit of TDR.

The purpose of this investigation is to work out how to export the *content*.
Exporting the metadata will be a separate piece of work.

There are a few constraints that we need to work with:

- The preservation ingest system expects the files to have their original names
  and be arranged in their original folder structure
- TDR will probably store the uploaded files in a flat file structure different
  to the original structure, and it will rename the files to have unique IDs
  like UUIDs. This makes it easier to process the files in storage, and means
  that we don't have to worry about file names that contain characters that S3
  doesn't support. We will store the original file name and full path in the
  database, so they can be matched to the S3 file later.
- The machines used to ingest the files are in a very isolated network.
  Archivists cannot browse the web on those machines, but there is a script
  which regularly copies files from an SFTP server to the Loader machine. This
  script is part of a system that is still a work-in-progress ([DALI]) and **may
  need some work** to make sure it copies and decrypts files correctly.

[DALI]: https://github.com/digital-preservation/dali/

## Proposed solution

Since the ingest system is isolated from the rest of the internet and there is
already a cron job which copies data to it from an SFTP server, a good solution
would be to copy data to that SFTP server.

We would create an export application which runs on demand, e.g. as an [ECS]
task in [AWS Fargate][fargate]. When an upload is ready for transfer to TNA,
this application would:

- Download all the uploaded files from S3
- Save the files with their original file names and paths, using the TDR API to
  look up the details using the S3 filename
- Zip the files into a single archive file
- Encrypt the zip file with a TNA public key
- Upload the encrypted zip to the TNA SFTP site

The script running on the Loader machine will:

- Check frequently for new files on the SFTP site
- Download new files
- Decrypt them with the TNA private key

As mentioned in the context, this script already exists but was part of a
work-in-progress project, so we expect we'll have to do some work to ensure it
downloads and decrypts the files correctly.

This solution means that from the digital archivist's perspective, ingesting
files is very similar to the current process.

It would also be useful to create at least one other FTP environment for testing
purposes. The test FTP servers don't need to have a much storage as the
production server, but they will let us test real FTP transfers in the dev, test
and staging environments.

[ECS]: https://aws.amazon.com/ecs/
[fargate]: https://aws.amazon.com/fargate/

### Export trigger

The export process would be triggered by an action on the TDR site. This will
probably be when the transferring body user marks the upload as ready for
transfer.

Alternatively, we could add a feature that lets the digital archivist control
when the  transfer happens. The implementation would be very similar in both
cases: the action would place a message on a queue, which triggers the export
task.

### Proof of concept

We've prototyped the export task (but not the trigger) in the
[tdr-prototype-file-export] project, and tested it with some sample data.

The prototype **does not do the file renaming step** because the API isn't ready
yet. We don't anticipate this step being a problem to implement, though we
should check the performance after it has been added because it will add a lot
of extra network calls.

#### Performance

We've tested the prototype with several collections of files. The files are not
real data, but randomly generated JPEG images.

The tests were run on ECS Fargate instances with the minimum task size settings:
0.5 GB of memory, and 0.25 vCPU.

The total time is the time between starting the ECS container and the zipped,
encrypted file being uploaded to the FTP server. **The total time is more than
the sum of the other columns** because it includes other processes, like
starting the container.

| Collection           | Download time | tar + gpg time | FTP upload time | Total time  |
| -------------------- | ------------- | -------------- | --------------- | ----------- |
| 1000 x 10 kB images  | 37 seconds    | 3 seconds      | 2 seconds       | 1 min 16 s  |
| 10000 x 10 kB images | 5 min 28 s    | 15 seconds     | 7 seconds       | 6 min 26 s  |
| 500 x 1.8 MB images  | 1 min 3 s     | 3 min 11 s     | 53 seconds      | 5 min 25 s  |
| 10 x 610 MB wavs     | 5 min 20 s    | 12 min 0 s     | 2 min 9s        | 19 min 45 s |

We expect the export times to be longer than this in practice because of the
extra API calls to get the original file names. We'll need to do some more
performance testing once that API endpoint exists. But at least these numbers
suggest that the performance is good enough - an export time in hours might be a
problem for the Digital Archivist who is going to ingest the data, but minutes
is a reasonable time to wait.

We can also try increasing the Fargate instance memory and CPU to speed up the
tasks if necessary.

### Scalability

The first iteration of TDR will only support uploading files through a web
interface, which will limit the size of files in the system to begin with.
Eventually, though, TDR may eventually have to support very large transfers or
individual files (tens of GB).

AWS S3 has no limit on the total size of a bucket, and the [maximum file
size][s3-file-size-limit] is 5 TB, much larger than the largest file we'd need
to support (tens of GB).

We might hit the storage limit in Fargate, though. You can [increase the storage
available in an EC2-based ECS container][ecs-storage-limit], but [AWS
Fargate][fargate] (serverless container hosting) currently has a [hard limit of
10 GiB][fargate-limits].

For the first iteration, we could accept the limit of 10 GB. In the future, we
could add batching to support transfers of more than 10 GB. This will need to
merge the transfers once they've been downloaded onto the ingest machines.
Batching would also let us process files in parellel, speeding up the transfer
to TNA.

If we need to support *individual files* of more than 10 GB, we'll either need
to build some kind of multi-part transfer or switch to using EC2 as a container
host.

[s3-file-size-limit]: https://aws.amazon.com/s3/faqs/
[ecs-storage-limit]: https://aws.amazon.com/premiumsupport/knowledge-center/increase-default-ecs-docker-limit/
[fargate-limits]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_limits.html

## Other options considered

We looked into several other export options which didn't look promising enough
to prototype.

### Download files directly from S3 via the TDR website

This is the most obvious way to export files, but it's not as simple as it
sounds:

- Browsers don't have an in-built way of linking to multiple simultaneous
  downloads
- You can download multiple files in JavaScript using the [download
  API][download-api], but it has limited browser support
- The files in S3 have different names and paths to the original files. There
  workarounds for this are not ideal:
  - The digital archivist could run an extra step to rename the files on their
    machine, which adds extra manual work
  - We could stream all the files through the TDR webserver to rename them,
    which would put a lot of extra load on the server
  - We could rename the files in the JavaScript layer, which adds lots of extra
    API requests in the user's browser
- After all that, the digital archivist still has to copy the files onto a hard
  disk and manually transfer them to the ingest system

[download-api]: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/downloads/download

### Download zip of transfer from the TDR website

We could zip the files in ECS in a similar way to the proposed solution, but
instead of uploading the files to FTP, the archivist would download them from
the TDR site.

This solves some of the problems in the previous solution because you only have
to download a single file, and the zip will contain the files with the correct
names and paths.

But the archivist will still have to do a manual transfer of the data, and we
may hit request timeouts like the [60 second CloudFront response
timeout][cloudfront-timeout] when downloading large transfers. You would have to
split the download or do a multipart transfer instead.

[cloudfront-timeout]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html#DownloadDistValuesOriginResponseTimeout

### AWS Transfer for SFTP

AWS have an [SFTP service][aws-sftp] which turns any S3 bucket into an FTP
server.

Archivists are on a network which blocks port 22, which means that they can't
transfer files via FTP to their own machines. (This doesn't affect the proposed
solution above because the FTP transfer runs on a machine on a different
network.)

AWS SFTP is also quite expensive: it currently costs $0.30 per hour for the
server (plus data transfer charges, though those would be small for our
expected usage).

[aws-sftp]: https://aws.amazon.com/sftp/

### AWS CLI

Running `aws s3 sync` in the [AWS CLI][aws-s3-cli] is the recommended way of
exporting multiple files from an S3 bucket.

We cannot run it on the preservation system because of network security rules,
but digital archivists could run it on their own machine.

We would still need to create a job which renames and zips the files - this
would just replace the FTP export step.

We've decided against it for TDR export for a few reasons:

- Digital archivists would have to learn how to use the AWS CLI
- We would have to manage IAM user accounts so they could log into the CLI
- They'll still have to manually transfer files from their machine to the ingest
  system

[aws-s3-cli]: https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html
