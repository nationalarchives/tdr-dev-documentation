# Frontend upload performance

Date: 2019-10-16

Transferring bodies often need to transfer large amounts of data to The National
Archives. Sometimes this involves a large number of small files, and sometimes
it means individually large files (e.g. videos). This will put a lot of pressure
on the upload part of TDR, because it needs to run computationally expensive
checksum calculations in the user's browser (which may be running on an old or
low-spec machine) and upload large files over the user's internet connection.

We don't expect the browser upload part of TDR to support the largest transfers,
but we want it to support as many transfers as possible, so we need to
understand and optimise the performance of the checksum calculation and upload.

These performance measurements don't include Internet Explorer, because it
[doesn't allow folder uploads][IE-testing] at all. We're coming up with a
separate plan to allow IE users to upload zip files instead.

[IE-testing]: internet_explorer.md

## Performance measurements

We've tested the performance by uploading the same sets of files in different
browsers and different computers.

The timings are recorded with console logs - see the logging in
[upload/index.ts][upload-code] for more details. We've measured:

- **File info time:** the time taken to extract details of all the files. Most
  of this time is due to the checksum calculation.
- **File info upload time:** the time taken to send all the file details to the
  TDR API.
- **S3 upload time:** the time taken to upload all the files to the AWS S3
  store.

The timings give a rough idea of which operations are slow, but they weren't run
in a very controlled environment so don't rely on the exact numbers. Most
uploads were only measured once (though we've rerun some of them a few times, so
we know they're roughly reproducible), and some were run on different days when
the network speeds might be slower or faster.

All tests were run in the AWS "dev" environment. Tests were run over the space
of a few days, and we didn't freeze the deployed version of the MVC or API apps.
But the upload code changed very little over that time (mostly to add more
performance logging) so the timing figures are still comparable to each other.

- MVC versions: 91d6035 to f33999d
- API version: 0aba975

[upload-code]: https://github.com/nationalarchives/tdr-prototype-mvc/blob/master/js-src/upload/index.ts

## Results

See [data/upload-performance.ods](data/upload-performance.ods) for the raw data
for each browser.

### Overall results

This table shows the range of results for several computers and browsers:

- CentOS 7 desktop with 32 GB of RAM, 8 x 3.6 GHz CPU and a wired internet
  connection
  - Google Chromium for Linux 73.0.3683.86
  - Firefox Quantum 60.9.0esr
- Windows 10 Enterprise laptop with 8 GB of RAM, 2.40 GHz CPU and connected to
  the TNA corporate wifi
  - Google Chrome for Windows 77.0.3865.120
  - Microsoft Edge 44.17763.1.0 (Microsoft EdgeHTML 18.17763)

| Collection            | File info time     | File info upload time | S3 upload time               |
| --------------------- | ------------------ | --------------------- | ---------------------------- |
| 1000 x 10 kB images   | 1.5 s - 1 min 40 s | 4.6 s - 6.2 s         | 1 min 30 s - **7 min 40 s**  |
| 10000 x 10 kB images* | 11 s - **17 min**  | 29 s - 42 s           | **9 min 20 s - 80 min**      |
| 500 x 1.8 MB images   | 11 s - 1 min 7 s   | 2.9 s - 4.5 s         | 2 min - **6 min 10 s**       |
| 1 x 610 MB wav        | 2.4 s - 11 s       | 0.9 s - 3.3 s         | 17 s - 55s                   |
| 10 x 610 MB wavs*     | 31 s - 1 min 20 s  | 0.8 s - 1.3 s         | 2 min 30 s - **10 min 40 s** |

Any steps which took over 5 minutes are shown in bold, to give a rough idea of
what types of upload might be frustrating for users.

Collections marked with \* do not include results for MS Edge. See the section
on Edge below.

In general, it looks like consignments with many small files are much slower
than consignments with a few large files, both in the checksum and the upload
steps.

It's also **not currently possible to upload very large files** (more than about
1 GB) because the checksum step loads the entire file into memory at once. We
have a plan for tackling this - see the Next Steps section below.

### Browser-specific results

#### Edge for Windows

##### Failures with large files

Edge currently fails when you try to upload a folder of multiple large files
(e.g. the 10 x 610 MB wav folder). It fails during the checksum calculation, and
it fails silently - the browser doesn't crash, and there are no errors in the JS
console. If you monitor Edge's memory usage, you can see it rise and fall as
each file is loaded into memory and then garbage-collected, but after a few
files it just stops and (apparently) never resumes.

We expect that we can fix this problem by streaming the file from disk rather
than loading it all into memory at once. The reason we don't do that at the
moment is that, for simplicity, we're using the brower's in-built
[`crypto.subtle.digest()`][crypto-subtle] to calculate the checksum, and it
requires the entire file at once.

There are alternatives, such as [asm-crypto], which can increment a hash with
new data, allowing you to read the file from disk incrementally. This is the
approach taken by [bagger-js].

[crypto-subtle]: https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/digest
[asm-crypto]: https://github.com/asmcrypto/asmcrypto.js
[bagger-js]: https://github.com/LibraryOfCongress/bagger-js

##### Slow file loading times

The folder selection step can be very slow when using Edge on Windows. When a
user browses to a folder and clicks "Select Folder", the time it takes for the
browser to show "X files selected" in the Browse element increases with the
number of files in the folder.

| Collection           | Approx. folder selection time |
| -------------------- | ----------------------------- |
| 1 x 610 MB wav       | 1 s - 4 s                     |
| 10 x 610 MB wavs     | 3 s - 5 s                     |
| 500 x 1.8 MB images  | 30 s                          |
| 1000 x 10 kB images  | 1 min                         |
| 10000 x 10 kB images | 50 min                        |

While this is happening, it's not clear to the user that anything is happening,
so they might click Browse again (which would reset the selection) or the Upload
button (which doesn't work until the files have loaded).

This is a [known issue in Edge][edge-folder-bug], but there's no sign that it's
going to be fixed soon. And even if it is fixed in a later version, some users
will still be on older versions and will still see this issue.

Since it looks like we can't solve the issue directly, ideally we'd indicate
that something _is_ happening. Unfortunately, that's also tricky because our
JavaScript code relies on the browser change events to fire, and the change
events are as slow as the visible change. We can detect when a user has clicked
the "Browse" button, which would let us show a loading indicator at the point
where a user starts to browser for a file, but we can't detect when a user
clicks Cancel, so there's no reliable way to hide the loading indicator if the
user changes their mind about browsing for files.

We've come up with some alternatives if we detect that a user is using Edge,
which all have downsides but are probably better than nothing:

- Warn the user that selecting a folder may take a while
- Suggest that they use a different browser (especially if they have a lot of
  files to upload)
- Suggest that the user selects a folder with drag-and-drop rather than browsing
  to the folder (or only let them use drag-and-drop). We know from user research
  that most users strongly prefer to browse to files because they can be more
  confident that they've selected the right thing, but we could give them the
  option. Drag-and-drop still loads the files slowly, but we can detect the drop
  event, so we can show a reliable loading indicator.
- Suggest or require the user to upload a zip instead of a folder, like we'll do
  for Internet Explorer users (who can't upload folders at all)

[edge-folder-bug]: https://developer.microsoft.com/en-us/microsoft-edge/platform/issues/17436000/

#### Firefox for Linux

The 10 x 610 MB dataset caused some problems during the upload step. On one
developer's machine, Firefox would crash almost every time after uploading a few
of the large files. We tried it on two other (almost identical) machines, and it
was fine.

The crash was a segfault, and it only happened when Developer Tools were open.
It happened even when we removed the checksum code, which is currently the most
memory-intensive step because it reads the whole file from disk, whereas the AWS
S3 SDK streams the file from disk.

The problem seems isolated to one machine, and it's unlikely to affect a real
user since we don't expect them to use the browser's developer tools while
uploading files. We'll keep an eye out for it, though.

## Conclusions and next steps

We now have a better understanding of how slow the upload will be for users.

We've also found the upload size is currently limited by the checksum step: it
fails on Edge for multiple 600 MB files, and on other browsers when an
individual file is larger than about 1 GB. But we think this can be fixed (see
below).

Next steps:

- Test the performance in other browsers, especially Safari, which we haven't
  tested yet beyond a few small files
- Investigate streaming the file into memory when calculating the checksum,
  which should let us upload arbitrarily large files (limited by the user's
  network speed and patience rather than by the browser's memory usage)
- Also investigate calculating the checksums in [WebAssembly], which might
  also improve the checksum performance where it's available
- Prioritise adding a progress indicator to the upload page, since checksum
  calculations and uploads for large files will take minutes or hours
- Choose which of the mitigations we should use to improve the user experience
  when selecting folders in Edge
- Try parallelizing the upload of small files, which are currently uploaded in
  series, making them slower than large files, which are batched and uploaded in
  parallel by the AWS S3 SDK
- Consider adding JS analytics to detect which browsers are used in practice, so
  we can work out many users are affected by things like:
  - IE not supporting folder uploads
  - Older versions of Safari not supporting file properties like `lastModified`
    and `webkitRelativePath`
  - Edge being slow to select large folders
- Look out for reports of crashes like the Firefox one, in case it does affect
  real users

[WebAssembly]: https://developer.mozilla.org/en-US/docs/WebAssembly
