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
`AZURE_AKS_POOL_MINIMUM_MAXPODS`          | `Azure_AKSNodeMinimumMaxPods`        | _TBA - not available_
`AZURE_RESOURCE_ALLOWED_LOCATIONS`        | `Azure_AllowedRegions`               | :octicons-milestone-24: v1.30.0
`AZURE_APIM_MINIMUM_CERTIFICATE_LIFETIME` | `Azure_MinimumCertificateLifetime`   | _TBA - not available_

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

### Realignment of rule names for network interfaces

Orginally when many of the rules targeting network interfaces were created, network interfaces only applied to virtual machines.
Today, network interfaces can be attached to different types of resources including:

- Virtual machines.
- Private endpoints.
- Private link services.

To better reflect that network interfaces are not only related to VMs, the following rules have been renamed:

- From `Azure.VM.NICAttached` to `Azure.NIC.Attached`.
- From `Azure.VM.NICName` to `Azure.NIC.Name`.
- From `Azure.VM.UniqueDns` to `Azure.NIC.UniqueDns`.

Aliases have been added to ensure any existing suppression and exclusion to these rules continues to work.

From _v2.0.0_ these aliases will no longer work.

To update your configuration, use the new rule names instead.
Possible locations where the old rule names may be used include:

- Within the `suppression` option defined within `ps-rule.yaml` or by using `New-PSRuleOption`.
- Within the `rule.exclude` or `rule.include` option defined within `ps-rule.yaml` or by using `New-PSRuleOption`.
- Within the `rule.exclude` or `rule.include` option defined within a custom baseline.
- Other custom scripts that run PSRule cmdlets directly.
