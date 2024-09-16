---
author: BernieWhite
discussion: false
---

# Deprecations

## Deprecations for v2.0.0

### Realigned configuration option names

The following configuration options will be renamed in upcoming releases of PSRule for Azure.
This is part of a ongoing effort to align the naming of configuration options across PSRule for Azure.

We plan to have all the old option names renamed and they will not longer work from v2.
To upgrade use the new names instead.
Until v2, the old option names are still work and will take precedence if new and old are configured.

New name                                  | Old name                             | Available from
--------                                  | --------                             | --------------
`AZURE_AKS_CLUSTER_MINIMUM_VERSION`       | `Azure_AKSMinimumVersion`            | :octicons-milestone-24: v1.12.0
`AZURE_AKS_POOL_MINIMUM_MAXPODS`          | `Azure_AKSNodeMinimumMaxPods`        | :octicons-milestone-24: v1.39.0
`AZURE_RESOURCE_ALLOWED_LOCATIONS`        | `Azure_AllowedRegions`               | :octicons-milestone-24: v1.30.0
`AZURE_APIM_MINIMUM_CERTIFICATE_LIFETIME` | `Azure_MinimumCertificateLifetime`   | :octicons-milestone-24: v1.39.0

!!! Note
    Configuration options marked _TBA_ are not available yet.
    Please use the old names until they are available.
    Check the [change log][1] and the [upgrade notes][2] for more information on a future release.

!!! Important
    New option names will work from the release specified by _Available from_.
    Configuring these options prior to that release will have no affect.
    For details on configuring these options see [upgrade notes][2] for details.

  [1]: CHANGELOG-v1.md
  [2]: upgrade-notes.md#realigned-configuration-option-names

### Realignment of rules

The Well-Architected Framework and PSRule are regularly updated.
As a result, some rules may not have a clear linkage with the latest guidance or practices.

To ensure that PSRule for Azure continues to provide clear guidance, examples, and references some rules will be removed.
The following rules are deprecated and will be removed in v2:

Reference ID | Name                             | Deprecated from | Reason
------------ | ----                             | --------------- | ------
AZR-000217   | Azure.Template.UseParameters     | v1.36.0         | Linting already handled by Bicep linter. No clear linkage to WAF.
AZR-000219   | Azure.Template.UseVariables      | v1.36.0         | Linting already handled by Bicep linter. No clear linkage to WAF.
AZR-000218   | Azure.Template.DefineParameters  | v1.36.0         | No applicable to Bicep. No clear linkage to WAF.
AZR-000233   | Azure.Template.ValidSecretRef    | v1.36.0         | Linting already handled by Bicep linter. No clear linkage to WAF.

Deprecated rules will not be run by default, but can be enabled by:

- Explicitly configuring the rule name or ID in the `Rule.Include` option, when a baseline not used.
- Adding the rule name or ID to the `Rule.Include` option in a custom baseline.

From v2, the deprecated rules will be removed and will no longer be available in new releases.
