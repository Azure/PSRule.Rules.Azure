---
author: BernieWhite
---

# Configuring rule defaults

PSRule for Azure include several rules that can be configured.
Setting these values overrides the default configuration with organization specific values.

## Configuration

!!! Tip
    Each of these configuration options are set within the `ps-rule.yaml` file.
    To learn how to set configuration options see [Configuring options][1].

  [1]: configuring-options.md

### AKS minimum Kubernetes version

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
  AZURE_AKS_CLUSTER_MINIMUM_VERSION: 1.21.9
```

Example:

```yaml
# YAML: Set the AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option to 1.22.4
configuration:
  AZURE_AKS_CLUSTER_MINIMUM_VERSION: 1.22.4
```

### AKS minimum max pods

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

### Allowed resource regions

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

### Minimum certificate lifetime

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

### Azure Policy maximum wavier

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

### Azure AKS CNI minimum cluster subnet size

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

### Additional region availability zone list

This configuration option adds availability zones that are not included in the existing [providers](https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/providers.json).
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
  - location: 'Antarctica North'
    zones:
      - "1"
      - "2"
      - "3"
  - location: 'Antarctica South'
    zones:
      - "1"
      - "2"
      - "3"
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

### Azure AKS enabled platform log categories list

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
  AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST: ['cluster-autoscaler', 'kube-apiserver', 'kube-controller-manager', 'kube-scheduler', 'AllMetrics']
```

Example:

```yaml
# YAML: Set the AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST configuration option to cluster-autoscaler and AllMetrics categories only. 
configuration:
  AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST: ['cluster-autoscaler', 'AllMetrics']
```

### Azure Automation Account enabled platform log categories list

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
  AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST: ['JobLogs', 'JobStreams', 'DscNodeStatus', 'AllMetrics']
```

Example:

```yaml
# YAML: Set the AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST configuration option to JobLogs and AllMetrics categories only. 
configuration:
  AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST: ['JobLogs', 'AllMetrics']
```