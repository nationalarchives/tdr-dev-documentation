## Droid vs Siegfried

We need software to carry out the file format checks on the files uploaded to TDR. There are two choices, [Siegfried](https://github.com/richardlehane/siegfried) and [Droid](https://github.com/digital-preservation/droid)

### Siegfried
#### Advantages
* Faster than Droid
* Outputs results to json

##### Disadvantages
* Doesn't report multiple patterns correctly. There is as [issue](https://github.com/richardlehane/siegfried/issues/146) where the maintainer says they will fix it but we don't know when that will be.

### Droid
#### Advantages 
* Reports files that contain multiple identification patterns correctly.
* Is developed by TNA so we have a lot more control over its development.

#### Disadvantages
* Slower than Siegfried.
* Reports are output in csv format which is more difficult to parse.

Although Droid is slower and more difficult to parse programmatically, it does report files with multiple matches correctly which is something that's important for TDR so we're going with Droid.