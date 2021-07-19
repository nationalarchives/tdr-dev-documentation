# 13. Use queues and Lambdas to run backend file checks

**Date:** 2021-01-27

## Context

When a user uploads a folder to a TDR consignment, TDR needs to run a set of
checks on each of those files. For the MVP release, the checks are:

- [Antivirus scan]
- [SHA-256 checksum], which can be compared to the checksum calculated in the
  user's browser
- [File format ID], which is useful metadata for the preservation system that
  ingests files transferred by TDR. It can be used to highlight files that The
  National Archives does not accept, like password-protected files, or files a
  user might have uploaded by mistake, like executable files

Files are uploaded to an S3 bucket, so we need a workflow that can run each scan
on each uploaded file. The user may upload several thousand files at once, and
the size could range from a few bytes to a few gigabytes.

We will warn the user that the file checks may take some time, but we think the
user experience will be better if the user can review the file check results as
soon as possible after uploading the files, so ideally this should take minutes
rather than hours.

We may add more file checks in future, such as additional checksum algorithms or
antivirus software. The architecture should be flexible enough to add or remove
checks later.

[Antivirus scan]: https://github.com/nationalarchives/tdr-antivirus/
[SHA-256 checksum]: https://github.com/nationalarchives/tdr-checksum/
[File format ID]: https://github.com/nationalarchives/tdr-file-format/

## Decision

Use AWS [Lambda] to run the file checks, and use [SQS] to coordinate the steps.

See the [architecture diagram] for how the file check workflow fits into the
overall architecture. The steps in the workflow are:

- A user uploads a file to S3 using the TDR frontend
- This triggers an upload event, which AWS sends to an SNS topic. The message
  contains the object's S3 key, which includes the TDR file ID UUID
- The message is passed to the first SQS queue
- A Lambda connected to the SQS queue takes the message, extracts the file ID,
  and [downloads the file][tdr-file-download] from S3 to an [EFS] temporary file
  store
- When that Lambda is finished, it adds a message to three further SQS queues,
  one for each of the backend checks
- Each SQS message triggers the respective backend check Lambda (checksum, file
  format ID and antivirus)
- Each Lambda sends a message to the API update SQS queue containing the results
  of the check
- A final Lambda picks up that message, and [sends the results to the consignment
  API][tdr-api-update], where they are stored in the database

Each check is a single, short process, which makes it very suitable for a
serverless workflow. If a user uploads thousands of files, we can process them
in parallel and let SQS and Lambda work through the backlog without having to
scale any EC2 instances. We are also trying to use serverless services on TDR
where possible because it removes the need to patch servers.

In all the testing so far, we haven't reached the maximum Lambda execution time
of 15 minutes. If we do hit those limits, we could consider moving the slow step
to an ECS task, which doesn't have an execution time limit but is slower to
start up. We would need some way to trigger the ECS task from SQS, but it would
otherwise fit into the workflow in the same way that Lambda does at the moment.

We considered using [step functions] instead of SQS to coordinate the tasks. We
decided against them because when we tried [using them in the Alpha
prototype][alpha-step-functions], we found that they failed when we hit the
Lambda concurrent usage limit. This is currently 1000 functions, and we can hit
this limit if a user uploads a consignment of thousands of small files. We don't
have this problem with SQS, because the messages wait in the queues until AWS
lets us start another Lambda.

The initial step of downloading the file from S3 to Lambda is necessary for the
antivirus and file format ID tasks, which need to access the file as if it was
on disk. The file is downloaded to EFS rather than to Lambda's disk storage. EFS
is a network file store, so access is slower than a local file on Lambda, but
the disk storage limit for Lambda is currently 512 MB, so EFS lets us run checks
on much larger files. All of the file check Lambdas then read the file from the
same EFS store, so the file only has to be downloaded once. This saves on
transfer and storage costs, and reduces the complexity of what the individual
file checks do.

We have a separate Lambda for sending the results to the API. This introduces
another SQS queue and Lambda, but it has several advantages over making each
file check send results to the API separately:

- If the API update step fails, we only have to retry the API update. We don't
  have to rerun the whole, potentially slow, file check
- We can choose to [throttle][lambda-throttling] the API update Lambda if the
  API cannot handle the load when receiving the results for thousands of files
  without reducing the throughput for the file checks themselves
- It reduces the number of API clients, which makes it easier to roll out API
  client library updates

The file checks do not apply any business logic. They just report the raw
results of the check. For example, if the file format ID step finds a zip file,
it reports the result. It will be up to the API to record this as a failure or a
warning.

The antivirus check does perform an action in addition to reporting the results:
it copies files to the "clean" or "quarantine" S3 buckets, depending on whether
the file passed or failed the virus scan. Files from the clean bucket are used
later in the TDR workflow, such as when exporting data. Files in the quarantine
bucket can be inspected by TDR admins if we want to find out more about why the
file failed the scan.

Each queue is configured to retry each message up to three times. If all the
attempts fail, the messages are sent to a dead letter queue. We will be able to
inspect messages in that queue and monitor the size of it to spot processing
problems.

[Lambda]: https://aws.amazon.com/lambda/
[SQS]: https://aws.amazon.com/sqs/
[architecture diagram]: ../beta-architecture/beta-architecture.md
[tdr-file-download]: https://github.com/nationalarchives/tdr-download-files/
[tdr-api-update]: https://github.com/nationalarchives/tdr-api-update/
[EFS]: https://aws.amazon.com/efs/
[step functions]: https://aws.amazon.com/step-functions/
[alpha-step-functions]: https://github.com/nationalarchives/prototype-state-machine
[lambda-throttling]: https://aws.amazon.com/about-aws/whats-new/2017/11/set-concurrency-limits-on-individual-aws-lambda-functions/

## Current limitations

### Load testing

At the time of writing, we haven't done any systematic load testing by uploading
very large files or consignments with large numbers of files. So we may need to
modify the architecture to deal with any performance issues that we find.

### Slow file format identification

We are using [DROID] to extract file format ID information. DROID was designed
to be run on folders of files, rather than on individual files as we are doing
in our Lambda function. This normally makes the file format ID step slower than
the antivirus and checksum steps.

If this becomes a problem (e.g. because users have to wait for hours for
results), then we could consider extracting the core logic of DROID so that it's
more suitable for running in a Lambda. We could also consider batching files,
which would require us to change how messages are passed between the steps.

[DROID]: https://github.com/digital-preservation/droid

### Potential concurrency issues

The results of a check should be identical if the check is repeated,
unless the file is replaced or if the check function is updated, for
example to update the antivirus or file format signatures.

At MVP, users will not have a way to replace a file. If TDR supports this in
future, e.g. so that users can replace a password-protected file with a
unencrypted one, we will have to think about how we store metadata for each
version of the file.

We will sometimes update the file checks. There is currently no way for a user
or an admin to rerun a file check, but it seems quite likely that we'll build
this functionality in order to rerun failed file checks. With the low volumes
and careful scrutiny of each transfer expected at MVP, we don't think there will
be any concurrency problems where old data overwrites new data. But the current
architecture, with its parallel file checks, does make this possible, so we
should revisit this and find a way to fix it. One option is to store a check
version number alongside the metadata, and use optimistic locking to prevent
metadata with an older version number from overwriting newer metadata. Another
option is to add pessimistic locks which prevent a new check for a given file
from starting until the old check has finished, but this is a significant change
to the architecture and could slow down processing.

Another possible concurrency issue comes from the temporary file store.
Currently, files are saved to a folder name based on the consignment ID. This
means that if a message is added to the queue for the same file, the file
downloader will try to download the file to the same location twice. This could
lead to conflicts, or to the file checks running on incomplete files. We could
fix this by saving the file to a unique folder (e.g. a UUID or the Lambda's task
ID), and passing it from the file download task to the file checks.

### No way to mark all checks as complete

Currently, we infer that the file checks are complete once the antivirus, file
format ID and checksum metadata are saved to the database for every file in the
consignment.

In the long term, we plan to also save some kind of consignment status so that
other processes can determine the state without having to inspect potentially
thousands of database rows. When we implement this, we'll have to decide _when_
to update that status. The results of each file check arrive independently, so
there's no obvious point when they're all finished without looking up all the
rest of the results.

## Later refinements

We discovered performance issues when large numbers of files were uploaded. We
didn't change the architecture described above, but we did decide to change some
of the configuration values. See [ADR 20] for more details.

[ADR 20]: 0020-sqs-visibility-timeout.md
