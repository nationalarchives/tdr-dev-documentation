# 19. Remove messages file from Transfer Digital Records frontend

**Date:** 2021-06-07

## Context

The [TDR frontend project] currently contains a file called [messages.conf],
which specifies all of the user-facing text shown by the frontend application.
This includes text like titles, links, error messages and longer guidance. The
HTML templates use the messages file by referencing a specific key. For example
`@Messages("upload.continueLink")` is replaced by 'Start upload' when the
template is rendered.

The messages.conf file is a standard method of internationalising an app, and is
[built into the Play framework][play-i18n]. We added it when we first started
building TDR in late 2019 because we thought we might have to add multiple
translations to the frontend.

It now seems quite unlikely that we'll need to add translations soon, and we've
encountered a few downsides to the messages file:

* It makes it harder to update the HTML templates, because content is referred
  to indirectly.
  * This is particularly difficult in content-heavy pages. See this [draft
    commit of the help guide][help-guide], for example, where it's very hard to
    follow the content on the page.
* It makes it harder to see whether the assertions are correct in the controller
  specs, because they test the message keys rather than the actual text
  ([example][test-example]).
* Not all of the text is actually in the HTML templates. Some of it is
  dynamically generated in the JavaScript layer ([example][js-example]).

[TDR frontend project]: https://github.com/nationalarchives/tdr-transfer-frontend
[messages.conf]: https://github.com/nationalarchives/tdr-transfer-frontend/blob/a87e1034191535aca0d756d88ff6be27fc5bc04c/conf/messages
[play-18n]: https://www.playframework.com/documentation/2.8.x/ScalaI18N
[help-guide]: https://github.com/nationalarchives/tdr-transfer-frontend/pull/424/commits/2eceb14a70f0e8f8609227d443fd3bafff23e24b
[test-example]: https://github.com/nationalarchives/tdr-transfer-frontend/blob/a87e1034191535aca0d756d88ff6be27fc5bc04c/test/controllers/TransferCompleteControllerSpec.scala#L18
[js-example]: https://github.com/nationalarchives/tdr-transfer-frontend/blob/c645aaa3c82326e826916454779ed340a59c94e1/npm/src/upload/upload-form.ts#L313-L315

## Decision

The dev team had a discussion on 2021-05-20, and there was a general consensus
that we should move the content out of the messages file and into the view
templates themselves.

If we ever do have to internationalise TDR (which isn't part of the upcoming
roadmap), we can revisit this decision. It may be that only some pages need to
be translated.

If we need to translate content-heavy pages like the help guide, it may be
better to do that with separate view templates rather than by putting every
title and paragraph into the messages file.

We have already started moving content out of the messages.conf file in [PR 661].

There is also a Jira card about tidying up the rest: [TDR-1160].

We may keep the [step numbers] in the messages file, because it is easier to
keep those consistent when they're in a config file rather than in each view,
but we could also move them to a different config file since the step numbers
aren't related to internationalisation.

[PR 661]: https://github.com/nationalarchives/tdr-transfer-frontend/pull/661
[TDR-1160]: https://national-archives.atlassian.net/browse/TDR-1160
[step numbers]: https://github.com/nationalarchives/tdr-transfer-frontend/blob/a87e1034191535aca0d756d88ff6be27fc5bc04c/conf/messages#L136-L144
