#25. Automatic code merging

**Date:** 2022-03-15

## Context
We have two services now, dependabot and Scala Steward, which create pull requests for dependency updates. 
We are getting around 5 or 6 of these per day which need to be merged in turn and can take a lot of time. We looked at using an automatic merging service to reduce the amount of time needed on merging dependency updates.

## Options considered
We considered continuing merging the pull requests manually.

The other choice was to use [Mergify](https://mergify.com/)

## Considerations
Because changes would be included in our service which a human hadn't seen before, we needed to make sure this was secure. 
The service needed able to allow the following:
* Restrict auto merging pull requests based on files changed. This way, we would only merge changes to dependency files.
* Restrict auto merging until after all tests and security checks are complete.

On top of this, the service should be well known and well established enough that we could be reasonably confident that it was secure and stable.

## Decision
We decided to use Mergify to merge our dependency updates. 

There are disadvantages around not having a human view every change committed to the repository but Mergify allows the checks mentioned above, so we can be confident that nothing malicious can be automatically merged.

This will save a lot of developer time, as they no longer need to spend time updating dependency upgrade pull requests.

It also makes sure that our dependencies are always at the latest version which means we are less likely to be affected by security vulnerabilities in our libraries.

Access to mergify is through SSO with GitHub credentials. This restricts access to users who have write access to the repository. 
It also means that when the user is removed from the nationalarchives organisation, their access to Mergify will be removed too.
