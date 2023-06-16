# TAG Security & Privacy Questionnaire Answers #

* **Author:** amaliev@google.com
* **Questionnaire Source:** https://www.w3.org/TR/security-privacy-questionnaire/#questions

## Questions ##

* **What information might this feature expose to Web sites or other parties, and for what purposes is that exposure necessary?**
  * We are not directly exposing new information.  We are deleting site state based on user behavior, however, and this does run the risk of leaking information about that user behavior.  We are mitigating this by fuzzing deletion time to make it harder to detect deletion and infer leaked information.
* **Is this specification exposing the minimum amount of information necessary to power the feature?**
  * Yes. Both user activation timestamps and stateful bounce timestamps are absolutely necessary for the feature.
* **How does this specification deal with personal information or personally-identifiable information or information derived thereof?**
  * This proposal does not deal with PII.
* **How does this specification deal with sensitive information?**
  * It doesn’t.
* **Does this specification introduce new state for an origin that persists across browsing sessions?**
  * Yes. For every eTLD+1 site, it stores the timestamp of the last user activation and the last stateful bounce on that origin. However, this data is cleared by a global timer, after an implementation-defined duration.
* **What information from the underlying platform, e.g. configuration data, is exposed by this specification to an origin?**
  * None.
* **Does this specification allow an origin access to sensors on a user’s device**
  * No.
* **What data does this specification expose to an origin? Please also document what data is identical to data exposed by other features, in the same or different contexts.**
  * None.
* **Does this specification enable new script execution/loading mechanisms?**
  * No.
* **Does this specification allow an origin to access other devices?**
  * No.
* **Does this specification allow an origin some measure of control over a user agent’s native UI?**
  * No.
* **What temporary identifiers might this this specification create or expose to the web?**
  * It tracks the last user activation and stateful bounce for each eTLD+1 site, as well as a set of bounced sites and sites that access storage for every navigation. However, these are eventually cleared. They are not directly exposed to the web, but they may be leaked to attackers who may be able to observe deleted site state in certain scenarios.  We mitigate this leakage by using an algorithm that makes it hard for an attacker to know when deletions will occur.
* **How does this specification distinguish between behavior in first-party and third-party contexts?**
  * We are interested primarily in first-party state, as bounce tracking can use it to simulate a 3P cookie on a different site. We also roll-up any 3P state accessed and attribute it to the top-level document.
* **How does this specification work in the context of a user agent’s Private \ Browsing or "incognito" mode?**
  * A user’s Private Browsing mode may have more restrictive settings to block third-party cookies. This proposal does not change that behavior or create new differences.
* **Does this specification have a "Security Considerations" and "Privacy Considerations" section?**
  * Yes.
* **Does this specification allow downgrading default security characteristics?**
  * No.