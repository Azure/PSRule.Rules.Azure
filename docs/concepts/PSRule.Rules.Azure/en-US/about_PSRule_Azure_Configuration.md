# PSRule_Azure_Configuration

## about_PSRule_Azure_Configuration

## SHORT DESCRIPTION

Describes PSRule configuration options specific to `PSRule.Rules.Azure`.

## LONG DESCRIPTION

PSRule exposes configuration options that can be used to customize execution of `PSRule.Rules.Azure`.
This topic describes what configuration options are available.

PSRule configuration options can be specified by setting the configuration option in `ps-rule.yaml`.
Additionally, configuration options can be configured in a baseline or set at runtime.
For details of setting configuration options see [PSRule options][options]

The following configurations options are available for use:

- [Azure_AKSMinimumVersion](#azure_aksminimumversion)
- [Azure_AKSNodeMinimumMaxPods](#azure_aksnodeminimummaxpods)
- [Azure_AllowedRegions](#azure_allowedregions)
- [Azure_MinimumCertificateLifetime](#azure_minimumcertificatelifetime)
- [AZURE_RESOURCE_GROUP](#azure_resource_group)
- [AZURE_SUBSCRIPTION](#azure_subscription)

### Azure_AKSMinimumVersion

This configuration option determines the minimum version of Kubernetes for AKS clusters and node pools.
Rules that check the Kubernetes version fail when the version is older than the version specified.

Syntax:

```yaml
configuration:
  Azure_AKSMinimumVersion: string # A version string
```

Default:

```yaml
# YAML: The default Azure_AKSMinimumVersion configuration option
configuration:
  Azure_AKSMinimumVersion: 1.16.7
```

Example:

```yaml
# YAML: Set the Azure_AKSMinimumVersion configuration option to 1.17.0
configuration:
  Azure_AKSMinimumVersion: 1.17.0
```

### Azure_AKSNodeMinimumMaxPods

This configuration option determines the minimum allowed max pods setting per node pool.
When an AKS cluster node pool is created, a `maxPods` option is used to determine the maximum number of pods for each node in the node pool.

Syntax:

```yaml
configuration:
  Azure_AKSNodeMinimumMaxPods: integer
```

Default:

```yaml
# YAML: The default Azure_AKSNodeMinimumMaxPods configuration option
configuration:
  Azure_AKSNodeMinimumMaxPods: 50
```

Example:

```yaml
# YAML: Set the Azure_AKSNodeMinimumMaxPods configuration option to 30
configuration:
  Azure_AKSNodeMinimumMaxPods: 30
```

### Azure_AllowedRegions

This configuration option specifies a list of allowed locations that resources can be deployed to.
Rules that check the location of Azure resources fail when a resource or resource group is created in a different region.

By default, `Azure_AllowedRegions` is not configured.
The rule `Azure.Resource.AllowedRegions` is skipped when no allowed locations are configured.

Syntax:

```yaml
configuration:
  Azure_AllowedRegions: array # An array of regions
```

Default:

```yaml
# YAML: The default Azure_AllowedRegions configuration option
configuration:
  Azure_AllowedRegions: []
```

Example:

```yaml
# YAML: Set the Azure_AllowedRegions configuration option to Australia East, Australia South East
configuration:
  Azure_AllowedRegions:
  - 'australiaeast'
  - 'australiasoutheast'
```

### Azure_MinimumCertificateLifetime

This configuration option determines the minimum number of days allowed before certificate expiry.
Rules that check certificate lifetime fail when the days remaining before expiry drop below this number.

Syntax:

```yaml
configuration:
  Azure_MinimumCertificateLifetime: integer
```

Default:

```yaml
# YAML: The default Azure_MinimumCertificateLifetime configuration option
configuration:
  Azure_MinimumCertificateLifetime: 30
```

Example:

```yaml
# YAML: Set the Azure_MinimumCertificateLifetime configuration option to 90
configuration:
  Azure_MinimumCertificateLifetime: 90
```

### Azure_Resource_Group

This configuration option sets the resource group object used by the `resourceGroup()` function.
Configure this option to change the resource group object when using exporting templates for analysis.
Provided properties will override the default.
Any properties that are not provided with use the defaults as specified below.

This configuration option will be ignored when `-ResourceGroup` is used with `Export-AzRuleTemplateData`.

Syntax:

```yaml
configuration:
  AZURE_RESOURCE_GROUP:
    name: string
    location: string
    tags: object
    properties:
      provisioningState: string
```

Default:

```yaml
# YAML: The default AZURE_RESOURCE_GROUP configuration option
configuration:
  AZURE_RESOURCE_GROUP:
    name: 'ps-rule-test-rg'
    location: 'eastus'
    tags: { }
    properties:
      provisioningState: 'Succeeded'
```

Example:

```yaml
# YAML: Override the location of the resource group object.
configuration:
  AZURE_RESOURCE_GROUP:
    location: 'australiasoutheast'
```

### AZURE_SUBSCRIPTION

This configuration option sets the subscription object used by the `subscription()` function.
Configure this option to change the subscription object when using exporting templates for analysis.
Provided properties will override the default.
Any properties that are not provided with use the defaults as specified below.

This configuration option will be ignored when `-Subscription` is used with `Export-AzRuleTemplateData`.

Syntax:

```yaml
configuration:
  AZURE_SUBSCRIPTION:
    subscriptionId: string
    tenantId: string
    displayName: string
    state: string
```

Default:

```yaml
# YAML: The default AZURE_SUBSCRIPTION configuration option
configuration:
  AZURE_SUBSCRIPTION:
    subscriptionId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
    tenantId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
    displayName: 'PSRule Test Subscription'
    state: 'NotDefined'
```

Example:

```yaml
# YAML: Override the display name of the subscription object
  AZURE_SUBSCRIPTION:
    displayName: 'My test subscription'
```

## NOTE

An online version of this document is available at https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/concepts/PSRule.Rules.Azure/en-US/about_PSRule_Azure_Configuration.md.

## KEYWORDS

- Configuration
- Rule

[options]: https://microsoft.github.io/PSRule/concepts/PSRule/en-US/about_PSRule_Options.html
