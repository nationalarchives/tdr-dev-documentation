# Test the accessibility of a feature

Transfer Digital Records needs to meet the [accessibility requirements for
public sector bodies][a11y-reqs], which means that every page and feature needs
to pass at least the AA level of the [Web Content Accessibility Guidelines
(WCAG)][wcag].

We think about accessibility when designing new features, and we periodically
check the accessibility of the whole site. Developers also need to test for
accessibility when building new features. This checklist is a subset of the full
WCAG AA standard. It includes checks which are particularly relevant to TDR,
and which can be checked fairly quickly by developers. We should keep this
checklist up-to-date as we learn more about testing TDR or if we add completely
new types of features, such as multimedia content.

[a11y-reqs]: https://www.gov.uk/guidance/accessibility-requirements-for-public-sector-websites-and-apps
[wcag]: https://www.w3.org/WAI/standards-guidelines/wcag/

## What to test

Some of these tests are subjective. For example, what is the most obvious and
logical tab order? If you are not sure about anything, talk to the rest of the
team to get other people's opinions, and to check whether it's something that
we should test with users.

### Manual tests

* Zoom into 400% and check the page is still readable and functional
* Disable images and styles (search for how to do this in your specific browser -
  instructions for Chrome are below) and check that the page is still readable
  and functional
* Check all functionality works using only the keyboard, and that you don't get
  stuck when tabbing through elements
* Check that it's obvious which element has focus when tabbing to it with the
  keyboard
* Check that keyboard tab order is obvious
* Check that semantic markup is used wherever possible (e.g. `<ul>` rather than
  `<div>` for a list, or `<h1>` rather than a styled `<span>` for a header)

### Screen reader tests

Navigate through the page using a screen reader. Choose one which works on your
operating system:

* [VoiceOver] for MacOS
* [NVDA] for Windows
* [Orca] for Linux

What to test with the screen reader:

* Check that the screen reader reads every element and header
* Check that every link makes sense in the screen reader
* Check that [ARIA roles] are used where appropriate (see the links section
  below for more about ARIA)
* Check that you can fill in every editable field
* Check that whenever an element appears or is updated dynamically, the screen
  reader announces the update in a way that is understandable

Ideally, we would also test every new page with a speech recognition tool like
[Dragon], but we don't currently have a licence.

[VoiceOver]: https://webaim.org/articles/voiceover/
[NVDA]: https://www.nvaccess.org/
[Orca]: https://help.gnome.org/users/orca/stable/
[ARIA roles]: https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles
[Dragon]: https://www.nuance.com/en-gb/dragon.html

### Automated tests

* Run either the [Chrome Lighthouse tool][lighthouse] or the [Firefox
Accessibility Inspector][firefox-ai], and review any
findings
* Run the [WebAIM WAVE browser extension][wave] on the new page, and review any
findings

[lighthouse]: https://developers.google.com/web/tools/lighthouse
[firefox-ai]: https://developer.mozilla.org/en-US/docs/Tools/Accessibility_inspector
[wave]: https://wave.webaim.org/

## Who should run the tests?

Anyone on the team can run these tests, but it should normally be one of the
developers who built the feature. This is to encourage all developers to get a
deeper understanding of accessibility. Also, it's often easier and quicker to
just fix something when you find an issue rather than reporting the problem to
someone else.

## When should we run the tests?

We should always go through the full checklist once the feature has been
deployed. Ideally, we should run the acccessibility checks on staging, since it
is a more stable environment, but testing on integration is OK if it's more
convenient.

It's also worth referring to the checklist during development, and doing some
testing in your development environment as you go. Some of the checks, such as
making sure we use semantic HTML elements, are easier to think about from the
start.

## Links

* [Digital Services frontend development guide](https://github.com/nationalarchives/front-end-development-guide/blob/master/development-guide.md)
* [GDS Service Manual: testing for accessibility](https://www.gov.uk/service-manual/helping-people-to-use-your-service/testing-for-accessibility)
* [18F accessibility checklist](https://accessibility.18f.gov/checklist/)
* [A11y project checklist](https://www.a11yproject.com/checklist/)
* [ARIA MDN docs](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA)

## Turning off images and CSS for Chrome

Within Chrome select the three horizontal dots in the upper right-hand corner and select 'Settings'.
Within the 'Settings' menu, go to 'Privacy and security', then 'Site settings'. Under the content heading,
you can choose to block or show images.

To block `CSS` styling follow the steps below:
* Access the TDR environment you wish to test (local or intg)
* Open the developer tools by right clicking anywhere on the page and selecting 'Inspect'
* Access the 'Network' tab
* Select 'Preserve log'
* Refresh the page - the dev tools should stay open
* Within the list of requests, find the file that ends with the extension `.css`
* Right click, select 'Block request URL'
* On the menu that appears, click the + sign
* Type in the following URL: `*.nationalarchives.gov.uk/*.css`
* Once you refresh, all styling should be removed. 
* These settings will be forgotten once you close the chrome tab/window