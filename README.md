# Navigational-Tracking Mitigations

This is expected to become a [Work Item](https://privacycg.github.io/charter.html#work-items)
of the [Privacy Community Group](https://privacycg.github.io/).

This originates out of a [proposal](https://github.com/privacycg/proposals/issues/6)
of the [Privacy Community Group](https://privacycg.github.io/); this work will have a
broader focus on all navigational tracking mechanisms.

The specification will eventually live in
https://privacycg.github.io/nav-tracking-mitigations/.

## Authors:

- Pete Snyder
- Jeffrey Yasskin

## Participate
- https://github.com/privacycg/nav-tracking-mitigations/issues

[You can generate a Table of Contents for markdown documents using a tool like [doctoc](https://github.com/thlorenz/doctoc).]

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Table of Contents

- [Introduction](#introduction)
- [Goals [or Motivating Use Cases, or Scenarios]](#goals-or-motivating-use-cases-or-scenarios)
- [Non-goals](#non-goals)
- [[API 1]](#api-1)
- [[API 2]](#api-2)
- [Key scenarios](#key-scenarios)
  - [Scenario 1](#scenario-1)
  - [Scenario 2](#scenario-2)
- [Detailed design discussion](#detailed-design-discussion)
  - [[Tricky design choice #1]](#tricky-design-choice-1)
  - [[Tricky design choice 2]](#tricky-design-choice-2)
- [Considered alternatives](#considered-alternatives)
  - [[Alternative 1]](#alternative-1)
  - [[Alternative 2]](#alternative-2)
- [Stakeholder Feedback / Opposition](#stakeholder-feedback--opposition)
- [References & acknowledgements](#references--acknowledgements)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Introduction

Browsers are working to prevent cross-site tracking, which threatens user
privacy. In addition to third-party cookies and storage, other client-side
methods exist that enable cross-site tracking. Navigational tracking correlates
user identities across sites during navigations between those sites.
Navigational tracking uses link decoration to convey information, but not all
link decoration is tracking. This project attempts to distinguish tracking from
non-tracking navigation and to prevent the tracking without damaging similar but
benign navigations.


## Goals [or Motivating Use Cases, or Scenarios]

[What is the **end-user need** which this project aims to address?]

## Non-goals

[If there are "adjacent" goals which may appear to be in scope but aren't,
enumerate them here. This section may be fleshed out as your design progresses and you encounter necessary technical and other trade-offs.]

## [API 1]

[For each related element of the proposed solution - be it an additional JS method, a new object, a new element, a new concept etc., create a section which briefly describes it.]

```js
// Provide example code - not IDL - demonstrating the design of the feature.

// If this API can be used on its own to address a user need,
// link it back to one of the scenarios in the goals section.

// If you need to show how to get the feature set up
// (initialized, or using permissions, etc.), include that too.
```

[Where necessary, provide links to longer explanations of the relevant pre-existing concepts and API.
If there is no suitable external documentation, you might like to provide supplementary information as an appendix in this document, and provide an internal link where appropriate.]

[If this is already specced, link to the relevant section of the spec.]

[If spec work is in progress, link to the PR or draft of the spec.]

## [API 2]

[etc.]

## Key scenarios

[If there are a suite of interacting APIs, show how they work together to solve the key scenarios described.]

### Scenario 1

[Description of the end-user scenario]

```js
// Sample code demonstrating how to use these APIs to address that scenario.
```

### Scenario 2

[etc.]

## Detailed design discussion

### [Tricky design choice #1]

[Talk through the tradeoffs in coming to the specific design point you want to make.]

```js
// Illustrated with example code.
```

[This may be an open question,
in which case you should link to any active discussion threads.]

### [Tricky design choice 2]

[etc.]

## Considered alternatives

[This should include as many alternatives as you can,
from high level architectural decisions down to alternative naming choices.]

### [Alternative 1]

[Describe an alternative which was considered,
and why you decided against it.]

### [Alternative 2]

[etc.]

## Stakeholder Feedback / Opposition

[Implementors and other stakeholders may already have publicly stated positions on this work. If you can, list them here with links to evidence as appropriate.]

- [Implementor A] : Positive
- [Stakeholder B] : No signals
- [Implementor C] : Negative

[If appropriate, explain the reasons given by other implementors for their concerns.]

## References & acknowledgements

[Your design will change and be informed by many people; acknowledge them in an ongoing way! It helps build community and, as we only get by through the contributions of many, is only fair.]

[Unless you have a specific reason not to, these should be in alphabetical order.]

Many thanks for valuable feedback and advice from:

- [Person 1]
- [Person 2]
- [etc.]
