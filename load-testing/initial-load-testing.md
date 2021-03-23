# Initial load testing

## Files used

A 3Gb, 40000 second wav file, created using ffmpeg.

2 2.8Gb bmp files created using ImageMagick's convert tool

2000 PDFs created using ImageMagick's convert tool

10000 PDFs created using ImageMagick's convert tool

These files have been uploaded to the tdr-upload-test-data bucket in the Sandbox environment if anyone wants to use them.

## Running the tests

I carried out the upload on a t3.medium EC2 instance with 2 CPU cores and 4GB RAM. Our first users will have a similar CPU with 8GB of RAM so the test machine is lower spec.

I did have to make some changes to various timeouts otherwise none of these would have worked.
* The akka request timeout on the API, which defaults to 20s, was switched off.
* The akka server timeout on the API, which defaults to 60s, was switched off.
* The load balancer idle timout, which was set at 60s, was increased to 10 minutes.

| File Type    | Number of files | File Size | Upload Time<sup>1</sup> | Backend metadata processing time<sup>2</sup>            | Export Time        |
|--------------|-----------------|-----------|-------------------------|---------------------------------------------------------|--------------------|
| wav          | 1               | 3Gb       | 80s                     | 150s                                                    | 288s               |
| bmp          | 2               | 2.8Gb     | 137s                    | 155s                                                    | 1092s              |
| random bytes | 1               | 5Gb       | 120s                    | 216s                                                    | Failed<sup>3</sup> |
| pdf          | 2000            | 1.9Kb     | ~600s                   | ~200 checks failed<sup>4</sup> after ~1200s<sup>5</sup> | n/a                |
| jpg          | 10000           | 160b      | Failed<sup>6</sup>      | n/a                                                     | n/a                |


<sup>1</sup>The upload time includes the time taken to upload the file and run the client side processing

<sup>2</sup>The backend processing time is the total time the backend checks took to run so the time taken by the slowest of the checks.

<sup>3</sup> The maximum size for a non multipart upload is 5Gb. Because this file was random bytes, gzip didn't compress it much so the consignment export size was over this limit.

<sup>4</sup> The api was responding too slowly so the API client in the download files lambda timed out.

<sup>5</sup> The majority of backend checks that did pass should have completed a lot faster because each check for an individual file should only take around 1 minute. This suggests that SQS is sending a lot of requests to each individual lambda which is increasing the time it takes.

<sup>6</sup> The browser crashed while trying to send the client side processing results to the API. The response json from the client metadata call is around 50Mb so the browser is running out of memory. I tried this in Chrome and Firefox. I did get the upload to succeed by using a t3.2xlarge which has 8 cores and 32Gb of RAM but this is much larger than the expected machines the users will use though.

## Problems found during the tests

###Timeouts
There are 4 timeouts that were preventing large consignments being processed.
* The akka request timeout. This is the maximum time a request can take
* The akka server timeout. The maximum time a server response can take. This needs to be the same as the request timeout as they basically do the same thing.
* The load balancer idle timout.
* The client timeout when contacting the API. When the API is overloaded, requests can take longer and the clients are timing out.

### Logging
There is little to no logging in the backend checks lambdas. The antivirus prints the current file id but the others only log errors. This makes it difficult to find out what has happened when there are a lot of files processed. Also, we get one line of a stack trace per cloudwatch event which makes them difficult to read.

### Client metadata api response json
We are returning a large json payload from the client metadata mutation which is consuming a lot of memory in the browser and causing the browser to crash on lower spec machines.

### No mulipart uploads in export task
We are using the single file upload call in the export task which has a size limit of 5Gb

### Parallelism in the backend check lambdas
It seems that AWS is passing a lot of messages to individual lambdas which is making them slow. We can reduce the number of messages passed to an individual lambda but this will increase the cost as more lambdas will run.

###Too many requests to the API
The API update lambda is making a single request for every file which is partly why the API runs so slowly under load. 

### API being overloaded
The API was responding very slowly under load although the CPU and memory usage never moved much above 50%. This causes numerous problems inculding clients timing out and the web app itself running slowly for other users.

### Lambda using all available memory
The checksum and antivirus lambdas use all their available memory for larger files. Increasing it may improve the speed of the check but we'd have to run some more tests to be sure.

## Potential fixes
I'm going to group these roughly into quick fixes, medium effort fixes and more difficult changes so we can see what we want to prioritise.

### Quick fixes
* Add more logging to the lambdas and fix the multiline formatting so stack traces are printed correctly.
* Change the graphql query used by the frontend to return less information.
* Change the export task to use multipart uploads.

### Medium effort fixes
* Change the timeouts mentioned above. Changing the timeouts won't be difficult but testing to see what they should be will take time.
* Set up auto scaling on the API ECS service. Again, setting it in terraform won't be difficult but tweaking the settings so they're useful will take time.

### Longer term fixes 
* Lambda profiling to determine the best number of input messages, the best amount of memory and the timeouts will help with the backend check processing speed but this will take a lot of time testing to see what they are and may end up not providing much improvement.
* Try to aggregate the API update process to prevent too many queries being sent to the API. This may need a restructuring of how the backend processes work so this won't be easy.