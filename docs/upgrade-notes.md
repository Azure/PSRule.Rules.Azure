---
discussion: false
---

# Upgrade notes

This document contains notes to help upgrade from previous versions of PSRule for Azure.

## Upgrading to v2.0.0

PSRule for Azure v2.0.0 is a planned _future_ release.
It's not yet available, but you can take these steps to proactively prepare for the release.

### Realigned configuration option names

Several configuration options will be renamed in upcoming releases of PSRule for Azure.
This is part of a ongoing effort to align the naming of configuration options across PSRule for Azure.
For information on other options that will be renamed see [deprecations][1].

You **only** need to take action if you have explicitly set old configuration option names.

The old option names may be set in:

- An option file such as `ps-rule.yaml`.
- A custom baseline.
- An environment variable.

To locate any configurations, search for the old option names within your Infrastructure as Code repo.

New name                                  | Old name                             | Available from
--------                                  | --------                             | --------------
`AZURE_AKS_CLUSTER_MINIMUM_VERSION`       | `Azure_AKSMinimumVersion`            | :octicons-milestone-24: v1.12.0
`AZURE_AKS_POOL_MINIMUM_MAXPODS`          | `Azure_AKSNodeMinimumMaxPods`        | :octicons-milestone-24: v1.39.0
`AZURE_RESOURCE_ALLOWED_LOCATIONS`        | `Azure_AllowedRegions`               | :octicons-milestone-24: v1.30.0
`AZURE_APIM_MINIMUM_CERTIFICATE_LIFETIME` | `Azure_MinimumCertificateLifetime`   | :octicons-milestone-24: v1.39.0

To update your configuration, use the new name instead.

  [1]: deprecations.md#realigned-configuration-option-names

!!! Note
    Environment variables are prefixed by `PSRULE_CONFIGURATION_` and are case sensitive.

=== "Options file"

    Set the `AZURE_AKS_CLUSTER_MINIMUM_VERSION` option in `ps-rule.yaml`.

    ```yaml
    # YAML: Set the AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option to 1.27.3
    configuration:
      AZURE_AKS_CLUSTER_MINIMUM_VERSION: 1.27.3
    ```

=== "Bash"

    Set the `PSRULE_CONFIGURATION_AZURE_AKS_CLUSTER_MINIMUM_VERSION` environment variable.

    ```bash
    # Bash: Set the AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option to 1.27.3
    export PSRULE_CONFIGURATION_AZURE_AKS_CLUSTER_MINIMUM_VERSION="1.27.3"
    ```

=== "GitHub Actions"

    Set the `PSRULE_CONFIGURATION_AZURE_AKS_CLUSTER_MINIMUM_VERSION` environment variable.

    ```yaml
    # GitHub Actions: Set the AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option to 1.27.3
    env:
      PSRULE_CONFIGURATION_AZURE_AKS_CLUSTER_MINIMUM_VERSION: '1.27.3'
    ```

=== "Azure Pipelines"

    Set the `PSRULE_CONFIGURATION_AZURE_AKS_CLUSTER_MINIMUM_VERSION` environment variable.

    ```yaml
    # Azure Pipelines: Set the AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option to 1.27.3
    variables:
    - name: PSRULE_CONFIGURATION_AZURE_AKS_CLUSTER_MINIMUM_VERSION
      value: '1.27.3'
    ```

### Realignment of rule names for network interfaces

Originally when many of the rules targeting network interfaces were created, network interfaces only applied to virtual machines.
Today, network interfaces can be attached to different types of resources including:

- Virtual machines.
- Private endpoints.
- Private link services.

To better reflect that network interfaces are not only related to VMs, the following rules have been renamed:

- From `Azure.VM.NICAttached` to `Azure.NIC.Attached`.
- From `Azure.VM.NICName` to `Azure.NIC.Name`.
- From `Azure.VM.UniqueDns` to `Azure.NIC.UniqueDns`.

Aliases have been added to ensure any existing suppression and exclusion to these rules continues to work.
However a warning will be displayed to indicate the an alias is being used.

To update your configuration, use the new rule names instead.
Possible locations where the old rule names may be used include:

- Within the `suppression` option defined within `ps-rule.yaml` or by using `New-PSRuleOption`.
- Within the `rule.exclude` or `rule.include` option defined within `ps-rule.yaml` or by using `New-PSRuleOption`.
- Within the `rule.exclude` or `rule.include` option defined within a custom baseline.
- Other custom scripts that run PSRule cmdlets directly.

### Removal of SupportsTags function

The `SupportsTags` function is a PowerShell function used for filtering rules.
Previously you could use this function to only run a rule against resources that support tags.
As of _v1.15.0_ this function has been deprecated for removal in the next major release _v2.0.0_.

From _v2.0.0_ the `SupportsTags` function will not longer work.

The `SupportsTags` function was previously only available for PowerShell rules and not well documented.
Instead you can use the `Azure.Resource.SupportsTags` selector introduced in _v1.15.0_.
This selector supports the the same features but also supports YAML and JSON rules in addition to PowerShell.

To upgrade your PowerShell rules use the `-With` parameter to set `Azure.Resource.SupportsTags`.
For example:

```powershell
# Synopsis: Old rule using the SupportsTags function
Rule 'Local.MyRule' -If { (SupportsTags) } {
  # Rule logic goes here
}

# Synopsis: Rule updated using the Azure.Resource.SupportsTags selector
Rule 'Local.MyRule' -With 'Azure.Resource.SupportsTags' {
  # Rule logic goes here
}
```

To read more about the selector, see [the documentation][2].

  [2]: en/selectors/Azure.Resource.SupportsTags.md
