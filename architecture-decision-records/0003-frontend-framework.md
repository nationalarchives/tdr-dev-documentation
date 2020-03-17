# 3. TDR frontend framework

**Date:** 2020-02-27

## Context

Transfer Digital Records needs a web interface to allow government users to
upload files to be transferred to The National Archives.

There are many frameworks to choose from when building user interfaces for the
web. Most modern programming languages have at least one widely-used server-side
web framework, such as Rails (Ruby), Node.js (JavaScript) or Spring (Java). There
are also many client-side JavaScript frameworks such as React, Vue or Angular.
These are optimised for presenting dynamic content that can be updated without a
full page reload.

## Considerations

The main considerations were:

- It should be straightforward for our team to develop and maintain the
  application. Developers in the Digital Archiving Department are generally
  familiar with Java and Scala, and our default choice for new code is Scala.
  Developers are also familiar with JavaScript for client-side development.
- It should support [progressive enhancement], so that as much of the site as
  possible is usable without JavaScript. (Though we know that the file upload
  page will require JavaScript so that we can run client-side file analysis.)

See the [our notes from the Alpha phase][alpha-considerations] for other
factors.

[progressive enhancement]: https://www.gov.uk/service-manual/technology/using-progressive-enhancement
[alpha-considerations]: ../technology-considerations/considerations_playmvc_vs_nextjs.md

## Prototyping

We considered the options in quite a lot of depth during the Alpha prototyping
phase. See [Front end technology considerations][alpha-considerations] and
the [Play MVC vs Next.js comparison][play-vs-next]. Also see the [list of Alpha
prototypes in this repo's README][alpha-prototypes].

[play-vs-next]: ../technology-considerations/software_evaluation_criteria_playmvc_vs_nextjs.md
[alpha-prototypes]: ../README.md#alpha-prototype-repos

## Decision

Use [Scala Play][play].

We chose Play over other MVC frameworks because we want to continue developing
in Scala.

We chose a server-side MVC framework over Next.Js, which was the other main
option that we prototyped, because we want to support progressive enhancement as
much as possible, and this is easier in a framework like Play whose main purpose
is server-side rendering.

Although Next.Js also supports server-side rendering, it's main purpose is to
speed up the rendering of React sites, so its purpose is more to enhance
client-side JavaScript than to support situations where JS isn't available or
fails to load.

Again, see [Front end technology considerations][alpha-considerations] and
the [Play MVC vs Next.js comparison][play-vs-next] for more considerations which
fed into the decision.

[play]: https://www.playframework.com/
