---
author: BernieWhite
---

# Configuring rule defaults

PSRule for Azure include several rules that can be configured.
Setting these values overrides the default configuration with organization specific values.

!!! Tip
    Each of these configuration options are set within the `ps-rule.yaml` file.
    To learn how to set configuration options see [Configuring options][1].

  [1]: configuring-options.md

### AZURE_AKS_CLUSTER_MINIMUM_VERSION

:octicons-milestone-24: v1.12.0

This configuration option determines the minimum version of Kubernetes for AKS clusters and node pools.
Rules that check the Kubernetes version fail when the version is older than the version specified.

Syntax:

```yaml
configuration:
  AZURE_AKS_CLUSTER_MINIMUM_VERSION: string # A version string
```

Default:

```yaml
# YAML: The default AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option
configuration:
  AZURE_AKS_CLUSTER_MINIMUM_VERSION: 1.25.6
```

Example:

```yaml
# YAML: Set the AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option to 1.22.4
configuration:
  AZURE_AKS_CLUSTER_MINIMUM_VERSION: 1.22.4
```

### AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE

This configuration option determines the minimum subnet size for Azure AKS CNI.

Syntax:

```yaml
configuration:
  AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE: integer
```

Default:

```yaml
# YAML: The default AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE configuration option
configuration:
  AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE: 23
```

Example:

```yaml
# YAML: Set the AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE configuration option to 26
configuration:
  AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE: 26
```

### AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST

This configuration option adds availability zones that are not included in the existing [providers](https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/providers/).
You can use this option to add availability zones that are not included in the default list.

The following providers are supported:

- `Microsoft.Compute/virtualMachineScaleSets`
- `Microsoft.Network/applicationGateways`
- `Microsoft.Network/publicIPAddresses`
- `Microsoft.ApiManagement/service`
- `Microsoft.Cache/Redis`
- `Microsoft.Cache/redisEnterprise`

The following rules and configuration options are supported:

- `Azure.AKS.AvailabilityZone` - `AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST`
- `Azure.AppGw.AvailabilityZone` - `AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST`
- `Azure.PublicIP.AvailabilityZone` - `AZURE_PUBLICIP_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST`
- `Azure.APIM.AvailabilityZone` - `AZURE_APIM_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST`
- `Azure.Redis.AvailabilityZone` - `AZURE_REDISCACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST`
- `Azure.RedisEnterprise.Zones` - `AZURE_REDISENTERPRISECACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST`

Syntax:

```yaml
configuration:
  AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: array
```

Default:

```yaml
# YAML: The default AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option
configuration:
  AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: []
```

Example:

```yaml
# YAML: Set the AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option to Antarctica North and Antarctica South, with zones 1, 2, 3.
configuration:
  AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST:
  - location: Antarctica North
    zones:
      - '1'
      - '2'
      - '3'
  - location: Antarctica South
    zones:
      - '1'
      - '2'
      - '3'
```

The above example, both these forms of location are accepted:

- `Antarctica North` or `antarcticanorth`
- `Antarctica South` or `antarcticasouth`

The rules normalize these location formats so either is accepted in the configuration.

!!! Note
    The above are examples for illustration purpose only.
    At the time of writing, `Antarctica North` and `Antarctica South` are fictional locations.
    If they do in the future exist, use this option add them prior to PSRule for Azure support.
    The above shows examples specific to `Azure.AKS.AvailabilityZone`, but behavior is consistent across all supported rules.

### AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST

This configuration option sets selective platform diagnostic categories to report on being enabled.

Syntax:

```yaml
configuration:
  AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST: array
```

Default:

```yaml
# YAML: The default AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST configuration option
configuration:
  AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST:
  - cluster-autoscaler
  - kube-apiserver
  - kube-controller-manager
  - kube-scheduler
  - AllMetrics
```

Example:

```yaml
# YAML: Set the AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST configuration option to cluster-autoscaler and AllMetrics categories only. 
configuration:
  AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST:
  - cluster-autoscaler
  - AllMetrics
```

### AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST

This configuration option sets selective platform diagnostic categories to report on being enabled.

Syntax:

```yaml
configuration:
  AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST: array
```

Default:

```yaml
# YAML: The default AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST configuration option
configuration:
  AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST:
  - JobLogs
  - JobStreams
  - DscNodeStatus
  - AllMetrics
```

Example:

```yaml
# YAML: Set the AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST configuration option to JobLogs and AllMetrics categories only. 
configuration:
  AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST:
  - JobLogs
  - AllMetrics
```

### Set the minimum MaxPods for a node pool

This configuration option determines the minimum allowed max pods setting per node pool.
When an AKS cluster node pool is created, a `maxPods` option is used to determine the maximum number of pods for each node in the node pool.

Depending on your workloads it may make sense to change this option:

- Micro-services/ web applications: 50+
- Data movement/ processing: 20-30

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

### AZURE_CONTAINERAPPS_RESTRICT_INGRESS

This configuration specifies whether if external ingress should be enabled or disabled.

Syntax:

```yaml
configuration:
  AZURE_CONTAINERAPPS_RESTRICT_INGRESS: boolean # An boolean value
```

Default:

```yaml
# YAML: The default AZURE_CONTAINERAPPS_RESTRICT_INGRESS configuration option
configuration:
  AZURE_CONTAINERAPPS_RESTRICT_INGRESS: false
```

Example:

```yaml
# YAML: Set the AZURE_CONTAINERAPPS_RESTRICT_INGRESS configuration option to enabled
configuration:
  AZURE_CONTAINERAPPS_RESTRICT_INGRESS: true
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
  - australiaeast
  - australiasoutheast
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

### AZURE_LINUX_OS_OFFERS

:octicons-milestone-24: v1.20.0

This configurations specifies names of offers corresponding to the Linux OS.
It's mostly intended to be used when analyzing templates that use private Linux offerings.
Rules that check if a VM or VMSS has Linux OS also validate against the values set by this configuration.

Syntax:

```yaml
configuration:
  AZURE_LINUX_OS_OFFERS: array # An array of offer names
```

Default:

```yaml
# YAML: The default AZURE_LINUX_OS_OFFERS configuration option
configuration:
  AZURE_LINUX_OS_OFFERS: []
```

Example:

```yaml
# YAML: Set the AZURE_LINUX_OS_OFFERS configuration option to aLinuxOffer, anotherLinuxOffer
configuration:
  AZURE_LINUX_OS_OFFERS:
  - 'aLinuxOffer'
  - 'anotherLinuxOffer'
```

### AZURE_POLICY_IGNORE_LIST

:octicons-milestone-24: v1.21.0

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
  AZURE_POLICY_RULE_PREFIX: Azure
```

Example:

```yaml
# YAML: Override the prefix of exported policy rules
  AZURE_POLICY_RULE_PREFIX: AzureCustomPrefix
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

### AZURE_STORAGE_DEFENDER_PER_ACCOUNT

:octicons-milestone-24: v1.27.0

This configuration option enables validation for that each storage account is associated with a Microsoft Defender for Storage resource level plan.
Configure this option to enable the per account validation, which defaults to `false`.

Syntax:

```yaml
configuration:
  AZURE_STORAGE_DEFENDER_PER_ACCOUNT: boolean
```

Default:

```yaml
# YAML: The default AZURE_STORAGE_DEFENDER_PER_ACCOUNT configuration option
configuration:
  AZURE_STORAGE_DEFENDER_PER_ACCOUNT: false
```

Example:

```yaml
# YAML: Set the AZURE_STORAGE_DEFENDER_PER_ACCOUNT configuration option to true
configuration:
  AZURE_STORAGE_DEFENDER_PER_ACCOUNT: true
```

### AZURE_VNET_DNS_WITH_IDENTITY

:octicons-milestone-24: v1.30.0

> Applies to [Azure.VNET.LocalDNS](../en/rules/Azure.VNET.LocalDNS.md).

Set this configuration option to `true` when DNS is deployed within the Identity subscription to avoid false positives.

When deploying Active Directory Domain Services (ADDS) within Azure, you may decide to:

- Deploy an Identity subscription aligned to the Cloud Adoption Framework (CAF) Azure landing zone architecture.
- Host DNS services on the same VMs as ADDS, located in a separate VNET spoke for the Identity subscription.

If you are using this configuration, we recommend you set the configuration option `AZURE_VNET_DNS_WITH_IDENTITY` to `true`.
By default, this configuration option is set to `false`.

Syntax:

```yaml
configuration:
  AZURE_VNET_DNS_WITH_IDENTITY: boolean # An boolean value
```

Default:

```yaml
# YAML: The default AZURE_VNET_DNS_WITH_IDENTITY configuration option
configuration:
  AZURE_VNET_DNS_WITH_IDENTITY: false
```

Example:

```yaml
# YAML: Set the AZURE_VNET_DNS_WITH_IDENTITY configuration option to enabled
configuration:
  AZURE_VNET_DNS_WITH_IDENTITY: true
```
