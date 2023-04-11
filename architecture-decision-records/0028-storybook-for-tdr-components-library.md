# 28. Using Storybook for TDR Components library

Date: 2023-03-14

## Context

[TDR Components](https://github.com/nationalarchives/tdr-components) is a library of front-end components currently based on the way [GDS Frontend](https://github.com/alphagov/govuk-frontend) is setup. Proposal is to replace the current setup of TDR Components with [Storybook](https://storybook.js.org/). 

That would involve replacing the current custom express app that renders UI with Storybook. And rewriting the UI/interaction tests written in Puppeteer with Storybook's built in testing-library. 

## Considerations

Current setup for TDR Components uses Jest, Puppeteer and Cherios to run UI/interaction and accessibility tests. To achieve this we have an express application that isolates each component in a page where Puppeteer can access it. This express setup is quite cumbersome and requires some manual addition of files and references to Sass and Typescript files.

Currently all interaction tests are written manually using Jest+Puppeter functions, which run on the CLI and during deployment. This is ok, but also quite laborious and provides no UI representation of the issue if tests fail. It is worth noting the proposed Storybook alternative only marginally reduces the amount of test code needed.

Storybook provides an out-of-box inteface that isolates each component UI state. You achieve this by writting 'Stories' in a Component Story Format (CSF). CSF is an open standard for UI component examples based on JavaScript ES6 modules. 

Each story is a JS or TS file that contain exports, which configure variations of the UI. Each variation is rendered in the Storybook interface allowing for much more detailed QA and acceptance testing for design, dev and other team members. 

Storybook provides a play function that 'is a small snippet of code that runs after a story finishes rendering. You can use this to test user workflows.' ([source](https://storybook.js.org/docs/react/writing-tests/interaction-testing)) Within the play function you can use a convenient [API from Testing-Library](https://testing-library.com/docs/queries/about) for querying the DOM. This library focusses on allowing you to access only the visible items or those made available to the [accessiblity tree](https://developer.mozilla.org/en-US/docs/Glossary/Accessibility_tree). As it states in the docs for this API:

>  (if you can't [use these functions to access the elements], it's possible your UI is inaccessible).

The elements state or content is then asserted against expectations using Jest functions. These tests run in the UI allowing us to see the visual/interactive outcomes of these tests. Crucially, with Storybook, all of these tests will also run on the CLI during deployment. 

Storybook also provides out-of-the-box accessibility testing using Axe Core, which would be a straight swap for existing setup. 

The interaction tests are run using storybook addons, which are effectively wrappers for Jest and Testing Library. This means we are paritially 'buying into' the ecosystem of Storybook, however there is evidence of the library's maturity and widespread use. The alternative is to write more verbose testing code for sometimes quite simple components. The labour saved amongst other benefits means we are more likely to write robust and comprehensive tests covering the multiple states a component can exist in. 

## Decision

After some exploratory testing of Storybook with the TDR Components library and comparison against the existing bespoke set-up using a Node/Express application we decided to implement Storybook and convert our existing tests to use the extensions built into Storybook. 

## Examples

Some examples of Storybook's use for managing design systems and componenet libraries across other large institutions. 

- [GOV.UK React | Component Encyclopedia | Storybook](https://storybook.js.org/showcase/govuk-react)
- [EU Europa Component Library | Component Encyclopedia | Storybook](https://storybook.js.org/showcase/eu-europa-component-library)
- [British Gas Nucleus | Component Encyclopedia | Storybook](https://storybook.js.org/showcase/british-gas-nucleus)
- [The Guardian Web | Component Encyclopedia | Storybook](https://storybook.js.org/showcase/the-guardian-web)
- Financial Times arre moving to it
- [NASA's Jet Propulsion Laboratory Explorer 1 | Component Encyclopedia | Storybook](https://storybook.js.org/showcase/nasa-jpl-explorer-1)

## Other possible future use cases
- Visual regression testing using Chromatic or other non-proprietary tool.
- A plug-in to connect Storybook to Figma - [In practice: GOV.UK’s design system](https://story.to.design/blog/in-practice-gov-uk-design-system)

