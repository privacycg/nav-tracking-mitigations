# Trigger Bounce Tracking Mitigations on HTTP Cache

_October 2024 - Andrew Liu_

> [!NOTE]
> This proposal is an early design sketch to describe the problem below and solicit feedback on the proposed solution. It has not been approved to ship in Chrome.

## Introduction

Chrome's initial proposed bounce tracking solution triggers when a site accesses browser storage (e.g. cookies) during a redirect flow. However, it's possible to craft a bounce tracker that does not require cookie access and instead uses only the HTTP cache. As a result, there exists a class of bounce trackers that can systematically evade the previously-proposed bounce tracking mitigations.

We propose dropping the requirement for a site to perform storage access during a bounce chain. While the initial concern was that benign stateless redirectors would suffer performance regressions, preliminary observation suggests that any performance impact would be negligible.

## Goals

* Detect bounce trackers that use techniques which don't involve browser storage access (e.g. ETag tracking).
* Avoid causing performance regressions with benign stateless redirectors (such as `gmail.com` or `outlook.com`).

## Use cases

Consider the following bounce chain:

1. The browser navigates to `site1.example`.
2. The site redirects to `tracker1.example`, passing any desired metadata in the HTTP headers.
3. Upon rendering, `tracker1.example` makes an AJAX request to `tracker2.example`.
4. The response from `tracker2.example` returns an ETag value that acts as a tracking ID. Subsequent requests to `tracker2.example` will send that ETag value within the `If-None-Match` request headers.
5. Upon completion of the AJAX request, `tracker1.example` redirects the browser to `site2.example`.

If the browser visits any other site that redirects to `tracker1.example`, the site will be able to retrieve the same ETag. None of the tracker sites used any cookie access. (The only state being persisted on the client is the HTTP cache.) Existing bounce tracking mitigations will not be able to detect this scenario.

See demos of this behavior [here][1] and [here][2]. They are identical demos hosted on different domains that can reach out to the same tracking URL. The ETag/tracking ID will be persisted, even though there's no cookie access.

## Proposed solution: remove storage access requirement as a triggering condition

We propose relaxing the triggering conditions for running bounce tracking mitigations by removing the requirement for a site to have performed storage access. In the scenario where a redirect chain bounces to a stateless tracker that leverages the HTTP cache, the tracker can be caught after the proposed changes.

Regarding performance implications, the hypothesis is that these changes will cause no performance impact, since most sites already set a low TTL for the HTTP cache.

## Preliminary performance impact analysis

To check whether ignoring storage access had any downstream performance impact, we conducted a few preliminary experiments on unstable versions of Chrome. There were some of the metrics we measured:

* For any given request, the HTTP response status code and whether the response was cached
* Cumulative load time for all server redirects within a redirect chain (and also measured for each individual server redirect)
* The time-to-first-byte for requests that are part of a redirect chain
* Initial load times of gmail.com

None of these metrics produced any statistically significant changes when adjusting the bounce tracking mitigation behavior.

It is important to note that these are preliminary investigations, rather than a definitive conclusion around performance. The above metrics can only demonstrate the presence of a regression; it cannot prove the absence of any performance regressions. However, given the lack of negative signal, it seems reasonable to proceed with further experimentation.

## Considered alternatives

Most alternatives revolved around relaxing the storage-access requirement only in certain specific situations. Hence they would all be strict subsets of the proposed approach.

* For redirects with non-permanent HTTP response status codes (e.g. 302), run bounce tracking mitigations if there were no user interactions with the site.
* For redirects that create client-side redirects, run bounce tracking mitigations if there were no user interactions with the site.
* In the case of performance regressions, we could alternatively delete stateless bounces after a longer delay (e.g. 12 or 24 hours). That way, some degree of HTTP caching could still take effect while not enabling long-term tracking.

Since the proposed approach is not expected to have performance regressions, none of the listed approaches are more appealing, since they only address a subset of the scenarios without any added benefit.

## Privacy and security considerations

These changes do not add any new privacy and security implications on top of the existing bounce tracking mitigation behavior.

[1]: https://cr.kungfoo.net/mrpickles/http_cache/explainer/
[2]: https://cr2.kungfoo.net/mrpickles/http_cache/explainer/

