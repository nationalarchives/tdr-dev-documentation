# Close a story or task

These checklists are intended to help us decide whether we can call a piece of
work "done".

In both cases, code review can be done by any other member of the team.
Particularly complex or security-critical code should be reviewed by someone
with a good understanding of the component being changed. Developers should use
their judgement to decide whether a task requires a more experienced reviewer.

## Stories

A story is "done" if:

* all code has been reviewed by another developer
* all the subtasks are merged to the "master" branch
* all the subtasks have been deployed to production (or staging, if we don't
  have a production environment available)
* another member of the team has tried the feature in the staging environment
  to check it against the acceptance criteria
* non-functional requirements such as security, accessibility and performance
  considerations are met - these should have been discussed [during sprint
  planning](plan-story.md) if they are relevant to the story
* any relevant documentation has been written or updated

## Tasks

A task is "done" if:

* the code has been reviewed by another developer
* the code is merged to the "master" branch
* the code has been deployed to production (or staging, if we don't have a
  production environment available)
* any relevant documentation has been written or updated
