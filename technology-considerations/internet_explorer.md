# Developing and Testing for Internet Explorer

## Problem

A key deliverable for the TDR project is to support users of Internet Explorer.
 
This raises some logistical challenges:
* Development is undertaken on Linux machines which do not support Internet Explorer
* Testing of code on Internet Explorer
 
## Possible Approaches
 
### Additional Hardware for Supporting Internet Explorer

Provide developer's with machines which support Internet Explorer and allow them to develop on

#### Problems

* Cost: cost of providing new hardware
 
### Browser Stack
 
Browser Stack (https://www.browserstack.com/local-testing) provides support for accessing local environments for testing, which can also be used for "real time development".
 
#### Problems

* Cost: requires a licence to access the needed featured. The cheapest package is $29.00 per month
* Testing Uploading: Browser Stack provides a limited set of files on the virtual machine that can be used for testing upload functionality
 
### Implement a CI AWS Environment

Create a CI AWS environment that would immediately deploy developer's changes so they can be access via another machine which has Internet Explorer installed

#### Problems

* Slow Development Cycle: developer's would still have to wait for the build/deployment before checking code changes
* Additional AWS Environment: require setting up and maintaining another AWS environment 
 
 