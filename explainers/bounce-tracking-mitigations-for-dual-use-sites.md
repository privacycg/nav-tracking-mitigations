# Bounce Tracking Mitigations for Dual-Use Sites

Alternatively: URL-Level Bounce Tracking Mitigations

## Authors:

- Svend Larsen, Google

## Participate

- [Issue tracker / discussion forum](https://github.com/privacycg/nav-tracking-mitigations/issues/106)

## Introduction

Under current [bounce tracking mitigations][1], mitigations are applied at the site (eTLD+1) level, and sites a user has recently interacted with are protected from mitigations. As acknowledged in the original bounce tracking mitigations explainer, using site-level interaction as a protection mechanism allows sites that are likely to get user interaction from a large number of users to do bounce tracking at scale. (Sites where the user knowingly interacts with a set of pages on the site, while another set of pages on the site does covert cross-site tracking, are hereafter referred to as "dual-use" sites.)

To combat a subset of bounce tracking by dual-use sites, this explainer proposes an identification mechanism and possible mitigation options for some suspected bounce tracking at the URL level, rather than the site level. This first step is aimed at bounce tracking on non-user-initiated navigations, which we observe in the wild. We say a URL is visited in a bounce-tracking-like context when the URL is accessed in a cross-site context via non-user-initiated navigations. We label a URL as a suspected bounce tracker if it has been visited in a bounce-tracking-like context and is not exempted via user trust indicators; this proposal suggests several such user trust indicators. This proposal also discusses two potential options for mitigations: a) blocking cookie access for suspected bounce tracker URLs, and b) partitioning cookies for suspected bounce tracker URLs on the tracker URL path and referring site.

## Goals

-  **Incrementally increase the scope of bounce tracking mitigations.** This proposal seeks to expand the scope of bounce tracking mitigations to include tracking performed by sites the user interacts with, when the user does not initiate navigation to or from the bounce tracker.
-  **Avoid breaking supported use cases valued by the user** that are implemented using bounces, even on sites where some URLs are classified as suspected bounce trackers under this proposal.
- **Mitigate the impact of short-lived domains or URLs** that may not be adequately addressed by other privacy interventions that rely on blocklists.

## Non-goals

-  **This proposal does not seek to enable bounce tracking mitigations when third-party cookies are enabled.** As noted in the original bounce tracking mitigations explainer, bounce tracking mitigations "largely only [add] value when third-party cookies are disabled. For the most part third-party cookies can be used to achieve the same results as bounce tracking. Therefore it is not a goal to enable these mitigations when third-party cookies are enabled."
-  **This proposal does not seek perfect prevention of bounce tracking** by dual-use sites. Since bounce tracking on a dual-use site is technically similar to several supported bounce use cases, this proposal seeks higher classification confidence at the potential cost of more coverage for the time being, with more incremental scope expansions possible in the future.
-  **Dual-use *URLs* are beyond the scope of this proposal.** Individual URLs used for both supported use case cases and unsupported bounce use cases will likely *not* be subjected to mitigations under this proposal. Dual-use URLs may be in scope for a future bounce tracking mitigations proposal, however.

## Detection mechanism for suspected bounce tracking

This proposal does not have any additional API surface, but instead changes the behavior of the browser.

The proposed mechanism for identifying suspected bounce tracker URLs has three high-level components:

1.  observe series of navigations that resemble bounce tracking and identify the bounce tracker candidate URLs from those navigation series;
2.  observe indicators of user trust;
3.  classify bounce tracker candidate URLs as either suspected bounce tracker URLs (subject to mitigations) or exempted (not subject to mitigations).

Each step could be done at the client level and/or in aggregate. The steps are described in more detail in the following subsections.

### Identifying bounce-tracking-like activity at the URL level

We say a URL is visited in a bounce-tracking-like context when the URL is accessed in a cross-site context via non-user-initiated navigations. (Throughout this proposal, "URL" refers to the 4-tuple of scheme, host, port, and path; other components such as query parameters and fragment are ignored.) More specifically, in a chain of two top-level navigations within a browser tab `[A->B, B->C]`, B is accessed in a cross-site context if B's eTLD+1 is different from the eTLD+1s of both A and C (regardless of whether A and C have the same eTLD+1 as each other or not).

To improve the accuracy of identifying bounce-tracking-like contexts, an optional enhancement would be to ignore contexts where B is same-party with either A or C; that is, if B's eTLD+1 belongs to the same party that the eTLD+1 for A or C belongs to. Same-party affiliation could be determined via commercially available association lists such as [Disconnect.me's entities list][3] and/or via the web platform's proposed [Related Website Sets][4] feature.

### Indicators of user trust

#### URL-aware user-directed navigation

When a URL is the target of a user-initiated navigation from outside of web content where it is highly likely that the user is aware of the URL itself, it seems highly likely that the URL should probably thus be exempted from classification as a suspected bounce tracker. Examples of this scenario include the user typing a URL into the browser's URL bar, or following a saved bookmark to a URL.

#### Qualifying user interaction in a bounce-tracking-like context

When a URL appears in a bounce-tracking-like context and the user has a qualifying interaction with that page within that context, that's a signal that the bounce may be for a supported use case. Qualifying interactions could include:

-  generating [user activation][2] during the visit;
-  generating user activation on another page on the same site during a bounce flow that starts with the URL; and
-  having a successful WebAuthn assertion during the visit.

#### Other indicators under consideration

Other possible indicators of user trust could include:

-  qualifying user interaction during a visit to the URL, regardless of whether it occurred in a bounce-tracking-like context or not (likely with a Bloom filter or other lookup time optimization);
-  query-param-based classification (if traffic through a URL uses params common to known-supported use cases, such as auth, in a manner consistent with that use case; i.e., simply looking at param names would be too naïve).

These potential indicators still need further study, however.

### Classification of bounce tracker candidate URLs

Once a URL has been identified as appearing in a bounce-tracking-like context and indicators of user trust (or lack thereof) have been observed, the browser must classify the URL as a likely bounce tracker or as likely performing a supported bounce use case.

It would be simpler if the browser could make this determination on-device. However, it may be necessary to perform classification on aggregated data from multiple clients on the server; if this is the case, classifications could be shared publicly among browser vendors for compatibility.

If classification is performed on-device, records of user trust indicators would need a TTL to prevent URLs with supported use cases from later being repurposed as tracker URLs.

## Mitigations

_**NOTE**: This section contains early discussion of possible ways to mitigate bounce tracking by dual-use sites._

There are multiple approaches that could be taken to mitigate suspected bounce tracking at the URL level, once identified. Some possible approaches are listed below; it's not yet clear which direction is most promising, or if another option not listed below would be better. Any mitigation applied to a URL is also intended to apply to its child frames.

### Block storage access

One possible direction is to completely block storage access for suspected bounce tracker URLs.

The browser would silently refuse browser storage write requests from such URLs, which might look like:

-  ignoring `Set-Cookie` headers;
-  ignoring JavaScript assignments to `document.cookie`;
-  resolving `CookieStore` `set` and `delete` requests with `undefined` but doing nothing;
-  denying access to `localStorage` and `sessionStorage`;
-  etc.

The browser would also show no results when such URLs read from browser storage, which might look like:

-  not sending `Cookie` headers in HTTP requests;
-  returning an empty string `""` on JavaScript `document.cookie` reads;
-  resolving `CookieStore` `get` requests with `undefined` and `getAll` requests with an empty list `[]`;
-  denying access to `localStorage` and `sessionStorage`;
-  etc.

One advantage of this approach is that it's simple — after being classified as a suspected bounce tracker, a URL has no storage access. Another advantage of this approach is that it would provide a more powerful protection against bounce tracking; the flipside is that any supported bounce use cases misclassified as suspected bounce trackers would be more severely impacted.

### Partition storage

Another possible direction is to partition storage written by URLs suspected of bounce tracking to mitigate tracking, while making it less likely that supported bounce use cases would be broken. That is, to partition storage such that, when bounced from site A to a tracker on site B, the tracker only knows about site B storage written during previous bounces from site A.

The partition would only be applied when the URL on site B has been classified as a suspected bounce tracker based on previous visits, and if the visit to the URL on site B looks like the start of a bounce-tracking-like flow.

The advantages and disadvantages are the reverse of those for blocking: Partitioning is more complicated than blocking, and provides a less complete protection against bounce tracking, but in the event that bouncers with supported use cases are classified as suspected bounce trackers, a partitioning-based mitigation allows for those URLs to retain some level of storage access.

An additional risk of this approach is the potential for confusion if a page with partitioned storage is shown to the user. For example, a site could show an active session with one account on a user-interest URL, while a suspected tracker URL on the same site might show an active session with a different account. Therefore, if partitioning is the chosen approach for mitigations, we should be careful to apply storage partitioning only to URLs we're confident will bounce without displaying content to the user.

An additional note about this approach is that partitioned cookies (as currently used in CHIPS) are opt-in, requiring the `Partitioned` attribute to be set. We could maintain the opt-in status for a mitigation under this proposal, which would require active changes from site maintainers to use. We could also introduce a new pattern of partitioning cookies by default, which wouldn't require active effort from developers, but it may be confusing for sites to receive and write partitioned cookies in a top-level context without explicitly requesting to do so.

## Key scenarios

### Single-use sites with supported bounce use cases

We aim to support (that is, not break) supported bounce use cases (notably including federated authentication and single sign-on) on single-use sites. See the original bounce tracking mitigations explainer's [Key Scenarios section][5] for more information on those use cases.

### Single-use sites with unsupported bounce use cases

Single-use sites with unsupported bounce use cases will continue to receive site-level bounce tracking mitigations; whether individual URLs on those sites also receive additional mitigations under this proposal should make little to no difference. See the original bounce tracking mitigations explainer's [Key Scenarios section][5] for more information.

### Dual-use sites

We aim to apply mitigations within dual-use sites only to URLs that perform engage in unsupported bounce use cases.

Let's say `example.com` offers an application the user values and frequently interacts with, hosted at `example.com/app`. Under this proposal, when the user visits `https://example.com/app`, the page can access cookies under `example.com` like normal. `https://example.com/app` does not appear in any bounce-tracking-like contexts, so it is never identified as a bounce tracker candidate URL under this proposal.

Let's say `example.com` also performs bounce tracking, with the tracker URL at `example.com/track`. Let's say `other.site` bounces to `https://example.com/track`, which bounces back to `other.site`. The tracker URL would receive mitigations under this proposal — if the blocking approach was chosen, `https://example.com/track` would not be able to read or write any cookies; if the partitioning approach was chosen, `https://example.com/track` would only be able to read and write cookies written during bounces to `https://example.com/track` from `other.site`.

Under this proposal, even after the browser classifies `https://example.com/track` as a suspected bounce tracker URL, `example.com/app` is still able to read and write cookies under `example.com` like normal. However, `example.com/app` can't read any cookies written by `https://example.com/track` after the latter was classified as a suspected bounce tracker URL, either because the latter URL was blocked from writing cookies in the first place, or because those cookies are partitioned.

## Incorporation of non-stable features

-  Browsers that wish to use [Related Website Sets (RWS)][4] to group sites for additional precision when identifying bounce-tracking-like contexts can do so, but it's not required by the proposal.

## Considered alternatives

### Human-written blocklists/allowlists

Human-written lists can have a negative impact on the web ecosystem both by creating barriers to entry for supported bouncers, and by not raising the barrier to entry for new trackers. We may be able to have more aggressive mitigations if we enshrine the current identity providers in an allowlist, but this could raise the cost for new identity providers to enter the market in the future. On the other hand, human-written blocklists are susceptible to evasion by smaller operators who can simply register new domains when their existing domains are blocked. One of our goals for this effort is to have mitigations that avoid this type of evasion, so this is a significant weakness.

### Interaction-based exemptions scoped to single referrers

To further reduce risk of bounce tracking, in-flow interaction exemptions could apply only for the specific referrers where the browser has observed in-flow interaction (for example, a tracker could have mitigations applied when referred from `a.com` but not when referred from `b.com`). This model likely puts too much burden of proof on bouncers with supported use cases in general, and seems likely to break SSO in particular. It also would add an additional layer of complexity and thus seems more likely to create confusion for users and developers.

### Exemptions by site attestation

Another option is to allow sites to publicly attest (e.g., via a `.well-known` file) that they are not performing bounce tracking on specific URLs. Large sites who would most benefit from dual-use bounce tracking may be discouraged from lying in attestations to maintain their brand image. However, we do not think this option is feasible, given the burden it would place on web developers and the simple evasion mechanism it would create for smaller sites who aren't as concerned about brand risk.

## Open questions

-  [Are there any indicators of user trust not enumerated in this explainer that should be included?](https://github.com/privacycg/nav-tracking-mitigations/issues/102)
   -  More specifically, are there any indicators of user trust that:
      -  have a high true-positive rate for supported bounce use cases;
      -  cover supported bounce use cases that the enumerated indicators do not cover; and,
      -  don't create an easily exploitable evasion mechanism for bounce trackers?
-  [Should classification of suspected bounce tracker URLs be done per client, in aggregate, or both?](https://github.com/privacycg/nav-tracking-mitigations/issues/103)
   -  If aggregated classification of suspected bounce tracker URLs should be done, what thresholds should be used for classification?
-  [What URL-level mitigation should be applied to suspected bounce tracker URLs?](https://github.com/privacycg/nav-tracking-mitigations/issues/104)

## Security & privacy considerations

### Cross-site leaks

Any time browsers take action based on a user's actual activity on a page, there's a risk of cross-site information leakage. We should aim to minimize cross-site leak risk as we make design choices.

#### Referrer policy

This proposal does not plan to take into account referrering pages' [referrer policy][6], as this proposal does not impact the [`Referer`][7] header. Depending on implementation details, this proposal may allow destination pages to infer some amount of information about their referrer that they wouldn't have been able to infer before. We should carefully balance the risk of referrer information leak against the privacy gains under this proposal.

### History clearing

Any browsing data used under this proposal should respect user requests to clear their browsing history.

## Future work

-  How to prevent URL rotation as an evasion mechanism?
   -  May involve performing bounce tracker classification on URL patterns rather than URLs.

## References & acknowledgements

Many thanks for valuable feedback and advice from:

- Andrew Liu, Google
- Ben Kelly, Google
- Brian Lefler, Google
- Giovanni Ortuño Urquidi, Google
- Ryan Tarpine, Google

[1]: https://github.com/privacycg/nav-tracking-mitigations/blob/main/explainers/bounce-tracking-mitigations.md
[2]: https://developer.mozilla.org/en-US/docs/Web/Security/User_activation
[3]: https://github.com/disconnectme/disconnect-tracking-protection
[4]: https://github.com/WICG/first-party-sets/
[5]: https://github.com/privacycg/nav-tracking-mitigations/blob/main/explainers/bounce-tracking-mitigations.md#key-scenarios
[6]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
[7]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referer
