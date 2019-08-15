# Developing and Testing for Internet Explorer

## Problem

A key deliverable for the TDR project is to support users of Internet Explorer.
 
This raises some operational challenges for development and testing:
* Development is undertaken on Linux machines which do not support Internet Explorer
* Testing of code on Internet Explorer
 
## Possible Approaches
 
### Additional Hardware for Supporting Internet Explorer

Provide developer's with machines which support Internet Explorer and allow them to develop on

#### Problems

* Cost: cost of providing new hardware
 
### Use Browser Stack
 
Browser Stack (https://www.browserstack.com/local-testing) provides support for accessing local environments for testing, which can also be used for "real time development".
 
#### Problems

* Cost: requires a licence to access the needed features. The cheapest package is $29.00 per month. There is a month-by-month package for $39.00
* **(REQUIRES CONFIRMATION)** Testing Uploading: Browser Stack provides a limited set of files on the virtual machine that can be used for testing upload functionality
* **(REQUIRES CONFIRMATION)** Stress Testing: Will not be possible because of unable to add required files to upload
 
### Implement a CI AWS Environment

Create a "CI" AWS environment that would immediately deploy developer's changes so they can be accessed via another machine which has Internet Explorer installed

#### Problems

* Slow Development Cycle: developer's would still have to wait for the build/deployment before checking code changes
* Additional AWS Environment: require setting up and maintaining another AWS environment with the additional costs this will entail
 
 