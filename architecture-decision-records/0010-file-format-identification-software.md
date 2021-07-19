# File format identification software

**Date:** 2020-09-01

## Context

We need software to carry out the file format checks on the files uploaded to TDR. There are two choices, [Siegfried](https://github.com/richardlehane/siegfried) and [Droid](https://github.com/digital-preservation/droid)

## Options considered

### Option 1: Siegfried

##### Advantages

* Faster than Droid
* Outputs results to json

##### Disadvantages
* Doesn't report multiple patterns correctly. There is as [issue](https://github.com/richardlehane/siegfried/issues/146) where the maintainer says they will fix it but we don't know when that will be.

### Option 2: Droid

#### Advantages 
* Reports files that contain multiple identification patterns correctly.
* Is developed by TNA so we have a lot more control over its development.

#### Disadvantages
* Slower than Siegfried. Running against the same file takes around 12 seconds for Droid and 1 second for Siegfried.
* Reports are output in csv format which is more difficult to parse.

## Decision
We did use Siegfried in the Alpha prototype because it was much easier to run it in a lambda before AWS added EFS volumes to lambda but with EFS, running Droid is almost as easy as running Siegfried

Droid is more difficult to parse programmatically but this is a one off cost. Once it's written, we won't have to change it too much. Droid is significantly slower but as we are running the file format checks in parallel, this isn't too big an issue. Droid reports files with multiple matches correctly which is something that's important for TDR and as it is a TNA project, we can add new features easily. 