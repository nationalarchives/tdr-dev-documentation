# Plan a user story

This guide is intended to help the team bring new stories into a sprint at the
sprint planning meeting. It should be used to prompt us to think about all the
aspects of a task like accessibility and security, rather than being a strict
process that we need to follow. If a card needs a different approach, we should
do that, and if we don't find these rules useful, we should change them.

## Common attributes

### Acceptance criteria

These should describe the actions that a user takes, what they see as a result,
and any other changes that we expect to take place (such as data being exported,
or a notification being sent).

Acceptance criteria should be agreed on by the developers and the product owner.

We normally write acceptance criteria in a Given/When/Then style, for example:

> As a transferring body user  
> When I go to the Dashboard page  
> Then I see a list of all my incomplete consignments  
> And each consignment is labelled with its creation date  

One advantage of writing acceptance criteria like this is that they can be used
as a starting point for writing automated tests, or can be followed by someone
testing the story manually.

If this format doesn't fit the story, don't use it. The important thing is that
it's obvious to someone testing the site whether it meets the criteria.

### Wireframes

The product owner should be happy with the UI designs before we start
development work.

### Subtasks

Breaking the story down into development tasks helps us uncover any hidden
complexity at planning time.

There are no strict rules for how we break down tasks. Two rough rules of thumb
are that each task should involve changing and deploying one project, and that
each task is expected to be a single pull request.

If we can't work out what the development tasks should be, we should ask why.
It might be a sign that we're not ready to start work on it, so a spike needs to
be done to work out what's possible.

### Estimate

A rough estimate of the complexity of a story. Estimating tasks accurately takes
a lot of time, so we use the [Fibonacci scale][fibonacci], which lets us compare
stories against each other and spot potentially huge tasks without worrying too
much about choosing a precise value.

[fibonacci]: https://en.wikipedia.org/wiki/Fibonacci_scale_(agile)

### Supporter

This is someone on the team who has done similar work before, or who knows a lot
about the context of a story. The aim of adding a Supporter is to make it easier
for any developer to pick up any card, because they know who to go to for help.

## Optional attributes

### Edge cases

Any ways the user might interact with the site, or data they might enter, that
is different to what we expect in a straightforward case. For example, uploading
files that cannot be identified by the file format checker.

We should be thinking about edge cases during development anyway, but we've
found that it's useful to talk about it in planning because different members of
the team suggest different types of edge cases that an individual developer
might not think of.

### End-to-end tests

Any [end-to-end tests][e2e] that should be written for this story. These tests
are slower and more fragile than unit tests, so we should only write them if
they provide a good signal that the main workflow is working or broken.

[e2e]: https://github.com/nationalarchives/tdr-e2e-tests/

### Exploratory testing

Complex stories, or ones which introduce new UI or backend components, are
likely to contain bugs that we didn't anticipate when writing automated tests.
At planning time, we should decide whether to include time for additional
[exploratory testing]. This might uncover bugs or just unanticipated workflows
that we should handle before a real user tries them.

Exploratory testing can be done by any member of the team who understands the
feature being tested. Ideally it should be someone who didn't contribute much
(or any) code to the feature, to avoid assumptions about how the application
_should_ behave. But it's often helpful for the person testing to know something
about the underlying components, because this can prompt them to explore
different edge cases.

[exploratory testing]: https://martinfowler.com/bliki/ExploratoryTesting.html

### Cross-browser testing

We don't currently have automated cross-browser testing because it would not be
worth the effort. The site which mostly works without JavaScript, and the UI is
based on the well-tested [GOV.UK Design System][govuk-design].

When we add or modify our own components, such as the upload progress bar, we
should test them in different browsers and on different operating systems. We
have a Browserstack subscription managed by Digital Services.

[govuk-design]: https://design-system.service.gov.uk/

### Accessibility considerations

We should consider whether any new components or interactions require any
accessibility design (such as [ARIA roles][aria]) or testing once the feature
is complete.

If we decide the feature needs accessibility testing, use the [accessibility
checklist].

[aria]: https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles
[accessibility checklist]: test-accessibility.md

### Security considerations

We should think about whether a new feature could potentially introduce security
vulnerabilities, and consider options for dealing with them.

Stories which will probably need extra security considerations include:

- Security features, e.g. login and user administration
- Stories about handling sensitive data
- Stories that add new access points to that data (e.g. backend or admin
  functions)

Ways to address the new risk could be:

- Deciding that the code changes should be reviewed by two people, or by someone
  who is particularly familiar with that part of the application
- Running a dedicated STRIDE workshop on the feature
- Adding security-focused automated tests
- Adding extra monitoring or scanning
