# PSRule_Azure_Configuration

## about_PSRule_Azure_Configuration

## SHORT DESCRIPTION

Describes PSRule configuration options specific to PSRule for Azure.

## LONG DESCRIPTION

PSRule exposes configuration options that can be used to customize execution of `PSRule.Rules.Azure`.
This topic describes what configuration options are available.

PSRule configuration options can be specified by setting the configuration option in `ps-rule.yaml`.
Additionally, configuration options can be configured in a baseline or set at runtime.
For details of setting configuration options see [PSRule options][1].

The following configurations options are available for use:

- [Azure_AKSMinimumVersion](#azure_aksminimumversion)
- [Azure_AKSNodeMinimumMaxPods](#azure_aksnodeminimummaxpods)
- [Azure_AllowedRegions](#azure_allowedregions)
- [Azure_MinimumCertificateLifetime](#azure_minimumcertificatelifetime)
- [AZURE_PARAMETER_FILE_EXPANSION](#azure_parameter_file_expansion)
- [AZURE_POLICY_WAIVER_MAX_EXPIRY](#azure_policy_waiver_max_expiry)
- [AZURE_RESOURCE_GROUP](#azure_resource_group)
- [AZURE_SUBSCRIPTION](#azure_subscription)
- [AZURE_POLICY_IGNORE_LIST](#azure_policy_ignore_list)
- [AZURE_POLICY_RULE_PREFIX](#azure_policy_rule_prefix)
- [AZURE_APIM_MIN_API_VERSION](#azure_apim_min_api_version)
- [AZURE_COSMOS_DEFENDER_PER_ACCOUNT](#azure_cosmos_defender_per_account)

  [1]: https://aka.ms/ps-rule/options

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
  Azure_AKSMinimumVersion: 1.20.5
```

Example:

```yaml
# YAML: Set the Azure_AKSMinimumVersion configuration option to 1.19.7
configuration:
  Azure_AKSMinimumVersion: 1.19.7
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

### AZURE_PARAMETER_FILE_EXPANSION

This configuration option determines if Azure template parameter files will automatically be expanded.
By default, parameter files will not be automatically expanded.

Parameter files are expanded when PSRule cmdlets with the `-Format File` parameter are used.

Syntax:

```yaml
configuration:
  AZURE_PARAMETER_FILE_EXPANSION: bool
```

Default:

```yaml
# YAML: The default AZURE_PARAMETER_FILE_EXPANSION configuration option
configuration:
  AZURE_PARAMETER_FILE_EXPANSION: false
```

Example:

```yaml
# YAML: Set the AZURE_PARAMETER_FILE_EXPANSION configuration option to enable expansion
configuration:
  AZURE_PARAMETER_FILE_EXPANSION: true
```

### AZURE_POLICY_WAIVER_MAX_EXPIRY

This configuration option determines the maximum number of days in the future for a waiver policy exemption.

Syntax:

```yaml
configuration:
  AZURE_POLICY_WAIVER_MAX_EXPIRY: integer
```

Default:

```yaml
# YAML: The default AZURE_POLICY_WAIVER_MAX_EXPIRY configuration option
configuration:
  AZURE_POLICY_WAIVER_MAX_EXPIRY: 366
```

Example:

```yaml
# YAML: Set the AZURE_POLICY_WAIVER_MAX_EXPIRY configuration option to 90
configuration:
  AZURE_POLICY_WAIVER_MAX_EXPIRY: 90
```

### AZURE_RESOURCE_GROUP

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

### AZURE_POLICY_IGNORE_LIST

This configuration option configures a custom list policy definitions to ignore when exporting policy to rules.
In addition to the custom list, a built-in list of policies are ignored.
The built-in list can be found [here](https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/policy-ignore.json).

Configure this option to ignore policy definitions that:

- Already have a rule defined.
- Are not relevant to testing Infrastructure as Code.

Syntax:

```yaml
configuration:
  AZURE_POLICY_IGNORE_LIST: array
```

Default:

```yaml
# YAML: The default AZURE_POLICY_IGNORE_LIST configuration option
configuration:
  AZURE_POLICY_IGNORE_LIST: []
```

Example:

```yaml
# YAML: Add a custom policy definition to ignore
  AZURE_POLICY_IGNORE_LIST:
  - '/providers/Microsoft.Authorization/policyDefinitions/1f314764-cb73-4fc9-b863-8eca98ac36e9'
  - '/providers/Microsoft.Authorization/policyDefinitions/b54ed75b-3e1a-44ac-a333-05ba39b99ff0'
```

### AZURE_POLICY_RULE_PREFIX

This configuration option sets the prefix for names of exported rules.
Configure this option to change the prefix, which defaults to `Azure`.

This configuration option will be ignored when `-Prefix` is used with `Export-AzPolicyAssignmentRuleData`.

Syntax:

```yaml
configuration:
  AZURE_POLICY_RULE_PREFIX: string
```

Default:

```yaml
# YAML: The default AZURE_POLICY_RULE_PREFIX configuration option
configuration:
  AZURE_POLICY_RULE_PREFIX: 'Azure'
```

Example:

```yaml
# YAML: Override the prefix of exported policy rules
  AZURE_POLICY_RULE_PREFIX: 'AzureCustomPrefix'
```

### AZURE_APIM_MIN_API_VERSION

This configuration option sets the minimum API version used for control plane API calls to API Management instances.
Configure this option to change the minimum API version, which defaults to `'2021-08-01'`.

Syntax:

```yaml
configuration:
  AZURE_APIM_MIN_API_VERSION: string
```

Default:

```yaml
# YAML: The default AZURE_APIM_MIN_API_VERSION configuration option
configuration:
  AZURE_APIM_MIN_API_VERSION: '2021-08-01'
```

Example:

```yaml
# YAML: Set the AZURE_APIM_MIN_API_VERSION configuration option to '2021-12-01-preview'
configuration:
  AZURE_APIM_MIN_API_VERSION: '2021-12-01-preview'
```

### AZURE_COSMOS_DEFENDER_PER_ACCOUNT

This configuration option enables validation for that each Cosmos DB account is associated with a Microsoft Defender for Cosmos DB resource level plan.
Configure this option to enable the per account validation, which defaults to `false`.

Syntax:

```yaml
configuration:
  AZURE_COSMOS_DEFENDER_PER_ACCOUNT: boolean
```

Default:

```yaml
# YAML: The default AZURE_COSMOS_DEFENDER_PER_ACCOUNT configuration option
configuration:
  AZURE_COSMOS_DEFENDER_PER_ACCOUNT: false
```

Example:

```yaml
# YAML: Set the AZURE_COSMOS_DEFENDER_PER_ACCOUNT configuration option to true
configuration:
  AZURE_COSMOS_DEFENDER_PER_ACCOUNT: true
```

## NOTE

An online version of this document is available at <https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/concepts/about_PSRule_Azure_Configuration.md>.

## KEYWORDS

- Configuration
- Rule
