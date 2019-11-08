# Frontend checksum options

Date: 2019-11-08

This is a follow-up to the more general [frontend upload performance
testing][perf-testing].

When we ran the original performance tests, we found that the size of the upload
was limited by the checksum calculation step. Our original approach to
calculating the checksum loaded the entire file into memory, which caused the
browser to hang for large files. Exactly how large depended on the environment:
Chrome and Firefox on Linux could cope with files up to about 2 GB, and Edge
could handle a single 600 MB file but not multiple files.

The current median transfer size is 6 GB, and we expect TDR to need to be able
to handle multi-GB files, so we tried two solutions:

- [Calculate the checksum incrementally in JavaScript][incremental-js]
- [Calculate the checksum incrementally in WebAssembly][incremental-wasm]

Both approaches read the files from disk into memory in chunks. The JavaScript
option uses the [asmcrypto.js] library to calculate the checksum. The other
option uses [WebAssembly], which allows websites to run compiled code in the
browser. This should be faster than JavaScript for processor-intensive tasks.
WebAssembly is [only available in some browsers][wasm-compatibility], but we can
fall back to JS when it's not available.

[perf-testing]: frontend_upload_performance.md
[incremental-js]: https://github.com/nationalarchives/tdr-prototype-mvc/pull/69
[incremental-wasm]: https://github.com/nationalarchives/tdr-prototype-mvc/pull/70
[asmcrypto.js]: https://github.com/asmcrypto/asmcrypto.js
[WebAssembly]: https://developer.mozilla.org/en-US/docs/WebAssembly
[wasm-compatibility]: https://developer.mozilla.org/en-US/docs/WebAssembly#Browser_compatibility

## Results

See [data/upload-performance.ods](data/upload-performance.ods) for the raw data
for each browser.

The results are for the same set of browsers as the [original performance
testing results][perf-testing].

Edge results are shown separately for two reasons: Edge performs very
differently to the other browsers tested, and it doesn't fully support
WebAssembly.

All the incremental results use 10 MB chunks. We tried different chunk sizes in
JS and WASM, and 10 MB seemed to be a reasonable compromise between speed
(larger chunks can be analysed faster) and memory usage (since we've seen
problems with the 600 MB files). We can tune this further if necessary.

| Collection            | Whole file         | Incremental in JS (Edge) | Incremental in JS (excluding Edge) | Incremental in WASM (excluding Edge) |
| --------------------  | ------------------ | ------------------------ | ---------------------------------- | ------------------------------------ |
| 1000 x 10 kB images   | 1.5 s - 1 min 40 s | 25 s                     | 3.8 s - 3.9 min                    | 2.2 s - 3 min 10 s                   |
| 10000 x 10 kB images* | 11 s - **17 min**  | 4 min                    | 37 s - **36 min**                  | 19 s - **30 min**                    |
| 500 x 1.8 MB images   | 11 s - 1 min 10 s  | **31 min**               | 14 s - 2 min                       | 20 s - 2 min 10 s                    |
| 1 x 610 MB wav        | 2.4 s - 11 s       | **19 min**               | 6.2 s - 22 s                       | 11 s - 32 s                          |
| 10 x 610 MB wavs*     | 31 s - 1 min 20 s  | ***7 h***                | 1 min 20 s - 4 min 20 s            | 2 min - **5 min 20 s**               |
| 1.6 GB random data    | -                  | **49 min**               | 16 s - 45 s                        | 27 s - 1 min 10 s                    |
| 5.4 GB random data    | -                  | ***3 h***                | 1 min 10 s - 1 min 50 s            | 1 min 40 s - 2 min 40 s              |

The main things to note are:

- Checksum generation is now possible in every browser, even for very large
  files
- Checksum generation for large files is _extremely_ slow in Edge
- For most browsers, incremental generation is slower than loading the whole
  file into memory, especially for small files
- WASM is actually slower than JS when calculating checksums for large files. We
  haven't investigated why this is, but it could be because most of the time is
  spent reading the file from disk, and this is the same in both JS and WASM,
  which has some extra overhead of calling the WASM code.

## Conclusions and next steps

- Now that we can calculate checksums for very large files, there is no longer a
  known technical limit on the size of the files users can upload to TDR. The
  practical limit will be based on the speed of the checksum generation and
  upload, and how long they're willing to wait.
- We might still be able to improve the performance, e.g. by using whole-file
  checksums for small files, and incremental checksums for larger ones, or by
  tuning the chunk size further.
- Edge is extremely slow for large files. We're planning to add a progress meter
  to the upload page, so users will be informed about how long they might have
  to wait, but it might be helpful to suggest a different browser.
- It's not worth using WebAssembly to generate checksums, presumably because the
  process is IO-bound rather than CPU-bound
- We still need to test on more browsers, including Safari
