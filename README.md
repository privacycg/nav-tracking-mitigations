# Navigation-based Tracking Mitigations

Work in this repository analyzes the problem of navigation-based cross-site
tracking and seeks to change browser behavior in order to prevent it. See the
**[Navigational-Tracking Mitigations
specification](https://privacycg.github.io/nav-tracking-mitigations/)** for more
details.

The [bounce tracking mitigations explainer](bounce-tracking-explainer.md)
outlines a proposal for aligning browsers on a common mitigation for bounce
tracking.

This is a [Work Item](https://privacycg.github.io/charter.html#work-items) of
the [Privacy Community Group](https://privacycg.github.io/). It originated out
of [proposal 6](https://github.com/privacycg/proposals/issues/6) of the [Privacy
Community Group](https://privacycg.github.io/), but this work focuses more
broadly on all navigation-based tracking mechanisms.

## Local development

The spec is written in [Bikeshed](https://speced.github.io/bikeshed/) and is
found in [`index.bs`](index.bs). You will need to install Bikeshed to build the
spec.

```sh
pipx install bikeshed
```

To build the spec, use the default Makefile target, and it will generate an
`index.html` containing the spec.

```sh
Make
```
