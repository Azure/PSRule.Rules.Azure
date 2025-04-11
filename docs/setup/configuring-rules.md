---
author: BernieWhite
---

# Configuring rule defaults

PSRule for Azure include several rules that can be configured.
Setting these values overrides the default configuration with organization specific values.

To use a configuration option, you **must** use the minimum version specified.
Earlier versions of PSRule for Azure will ignore the configuration option.

!!! Tip
    Each of these configuration options are set within the `ps-rule.yaml` file.
    To learn how to set configuration options see [Configuring options][1].

  [1]: index.md

## Available options

### AZURE_AI_SERVICES_NAME_FORMAT

<!-- module:version v1.43.0 -->
<!-- module:rule Azure.AI.Naming -->

This configuration option specifies a regular expression that defines the naming format for Azure AI Services.
When this configuration option is not set, any name is considered valid.

The regular expression used to specify the naming format is case-sensitive by default.
You can use the `(?i)` prefix to make the regular expression case-insensitive.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_AI_SERVICES_NAME_FORMAT: string
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_AI_SERVICES_NAME_FORMAT configuration option
configuration:
  AZURE_AI_SERVICES_NAME_FORMAT: ''
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_AI_SERVICES_NAME_FORMAT configuration option to a specific format
configuration:
  AZURE_AI_SERVICES_NAME_FORMAT: '^ais-'
```

### AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST

<!-- module:rule Azure.AKS.AvailabilityZone -->

This configuration option adds availability zones that are not included in the existing [providers](https://github.com/Azure/PSRule.Rules.Azure/tree/main/data/providers/).
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

```yaml title="ps-rule.yaml"
configuration:
  AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: array
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option
configuration:
  AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: []
```

Example:

```yaml title="ps-rule.yaml"
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

### AZURE_AKS_CLUSTER_MINIMUM_SYSTEM_NODES

<!-- module:version v1.34.0 -->
<!-- module:rule Azure.AKS.MinNodeCount -->

This configuration option determines the minimum number of nodes in an AKS clusters across all system node pools.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_AKS_CLUSTER_MINIMUM_SYSTEM_NODES: integer
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_AKS_CLUSTER_MINIMUM_SYSTEM_NODES configuration option
configuration:
  AZURE_AKS_CLUSTER_MINIMUM_SYSTEM_NODES: 3
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_AKS_CLUSTER_MINIMUM_SYSTEM_NODES configuration option to 2
configuration:
  AZURE_AKS_CLUSTER_MINIMUM_SYSTEM_NODES: 2
```

### AZURE_AKS_CLUSTER_MINIMUM_VERSION

<!-- module:version v1.12.0 -->
<!-- module:rule Azure.AKS.Version -->

This configuration option determines the minimum version of Kubernetes for AKS clusters and node pools.
Rules that check the Kubernetes version fail when the version is older than the version specified.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_AKS_CLUSTER_MINIMUM_VERSION: string # A version string
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option
configuration:
  AZURE_AKS_CLUSTER_MINIMUM_VERSION: 1.30.10
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option to 1.22.4
configuration:
  AZURE_AKS_CLUSTER_MINIMUM_VERSION: 1.22.4
```

### AZURE_AKS_CLUSTER_USER_POOL_EXCLUDED_FROM_MINIMUM_NODES

<!-- module:version v1.34.0 -->
<!-- module:rule Azure.AKS.MinUserPoolNodes -->

This configuration option excludes specific user node pools by name from requiring a minimum number of nodes.
By default, no user node pools are configured to be excluded.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_AKS_CLUSTER_USER_POOL_EXCLUDED_FROM_MINIMUM_NODES: array
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_AKS_CLUSTER_USER_POOL_EXCLUDED_FROM_MINIMUM_NODES configuration option
configuration:
  AZURE_AKS_CLUSTER_USER_POOL_EXCLUDED_FROM_MINIMUM_NODES: []
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_AKS_CLUSTER_USER_POOL_EXCLUDED_FROM_MINIMUM_NODES configuration option to exclude nodepool2
configuration:
  AZURE_AKS_CLUSTER_USER_POOL_EXCLUDED_FROM_MINIMUM_NODES:
  - nodepool2
```

### AZURE_AKS_CLUSTER_USER_POOL_MINIMUM_NODES

<!-- module:version v1.34.0 -->
<!-- module:rule Azure.AKS.MinUserPoolNodes -->

This configuration option determines the minimum number of nodes in each user node pool for an AKS clusters.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_AKS_CLUSTER_USER_POOL_MINIMUM_NODES: integer
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_AKS_CLUSTER_USER_POOL_MINIMUM_NODES configuration option
configuration:
  AZURE_AKS_CLUSTER_USER_POOL_MINIMUM_NODES: 3
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_AKS_CLUSTER_USER_POOL_MINIMUM_NODES configuration option to 2
configuration:
  AZURE_AKS_CLUSTER_USER_POOL_MINIMUM_NODES: 2
```

### AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE

<!-- module:version v1.7.0 -->
<!-- module:rule Azure.AKS.CNISubnetSize -->

This configuration option determines the minimum subnet size for Azure AKS CNI.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE: integer
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE configuration option
configuration:
  AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE: 23
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE configuration option to 26
configuration:
  AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE: 26
```

### AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST

<!-- module:version v1.8.0 -->
<!-- module:rule Azure.AKS.PlatformLogs -->

This configuration option sets selective platform diagnostic categories to report on being enabled.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST: array
```

Default:

```yaml title="ps-rule.yaml"
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

### AZURE_AKS_POOL_MINIMUM_MAXPODS

<!-- module:version v1.39.0 -->
<!-- module:rule Azure.AKS.NodeMinPods -->

This configuration option determines the minimum allowed max pods setting per node pool.
When an AKS cluster node pool is created, a `maxPods` option is used to determine the maximum number of pods for each node in the node pool.

Depending on your workloads it may make sense to change this option:

- Micro-services/ web applications: 50+
- Data movement/ processing: 20-30

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_AKS_POOL_MINIMUM_MAXPODS: integer
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_AKS_POOL_MINIMUM_MAXPODS configuration option
configuration:
  AZURE_AKS_POOL_MINIMUM_MAXPODS: 50
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_AKS_POOL_MINIMUM_MAXPODS configuration option to 30
configuration:
  AZURE_AKS_POOL_MINIMUM_MAXPODS: 30
```

### AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST

<!-- module:version v1.8.0 -->
<!-- module:rule Azure.AppGw.AvailabilityZone -->

This configuration option adds availability zones that are not included in the existing [providers](https://github.com/Azure/PSRule.Rules.Azure/tree/main/data/providers/).
You can use this option to add availability zones that are not included in the default list.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: array
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option
configuration:
  AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: []
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option to Antarctica North and Antarctica South, with zones 1, 2, 3.
configuration:
  AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST:
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

### AZURE_APIM_MINIMUM_CERTIFICATE_LIFETIME

<!-- module:version v1.39.0 -->
<!-- module:rule Azure.APIM.CertificateExpiry -->

This configuration option determines the minimum number of days allowed before certificate expiry.
Rules that check certificate lifetime fail when the days remaining before expiry drop below this number.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_APIM_MINIMUM_CERTIFICATE_LIFETIME: integer
```

Default:

```yaml
# YAML: The default AZURE_APIM_MINIMUM_CERTIFICATE_LIFETIME configuration option
configuration:
  AZURE_APIM_MINIMUM_CERTIFICATE_LIFETIME: 30
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_APIM_MINIMUM_CERTIFICATE_LIFETIME configuration option to 90
configuration:
  AZURE_APIM_MINIMUM_CERTIFICATE_LIFETIME: 90
```

### AZURE_APIM_MIN_API_VERSION

<!-- module:version v1.22.0 -->
<!-- module:rule Azure.APIM.MinAPIVersion -->

This configuration option sets the minimum API version used for control plane API calls to API Management instances.
Configure this option to change the minimum API version, which defaults to `'2021-08-01'`.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_APIM_MIN_API_VERSION: string
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_APIM_MIN_API_VERSION configuration option
configuration:
  AZURE_APIM_MIN_API_VERSION: '2021-08-01'
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_APIM_MIN_API_VERSION configuration option to '2021-12-01-preview'
configuration:
  AZURE_APIM_MIN_API_VERSION: '2021-12-01-preview'
```

### AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST

This configuration option sets selective platform diagnostic categories to report on being enabled.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST: array
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST configuration option
configuration:
  AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST:
  - JobLogs
  - JobStreams
  - DscNodeStatus
  - AllMetrics
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST configuration option to JobLogs and AllMetrics categories only.
configuration:
  AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST:
  - JobLogs
  - AllMetrics
```

### AZURE_CONTAINERAPPS_RESTRICT_INGRESS

This configuration specifies whether if external ingress should be enabled or disabled.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_CONTAINERAPPS_RESTRICT_INGRESS: boolean
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_CONTAINERAPPS_RESTRICT_INGRESS configuration option
configuration:
  AZURE_CONTAINERAPPS_RESTRICT_INGRESS: false
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_CONTAINERAPPS_RESTRICT_INGRESS configuration option to enabled
configuration:
  AZURE_CONTAINERAPPS_RESTRICT_INGRESS: true
```

### AZURE_COSMOS_DEFENDER_PER_ACCOUNT

This configuration option enables validation for that each Cosmos DB account is associated with a Microsoft Defender for Cosmos DB resource level plan.
Configure this option to enable the per account validation, which defaults to `false`.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_COSMOS_DEFENDER_PER_ACCOUNT: boolean
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_COSMOS_DEFENDER_PER_ACCOUNT configuration option
configuration:
  AZURE_COSMOS_DEFENDER_PER_ACCOUNT: false
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_COSMOS_DEFENDER_PER_ACCOUNT configuration option to true
configuration:
  AZURE_COSMOS_DEFENDER_PER_ACCOUNT: true
```

### AZURE_DEPLOYMENT_NONSENSITIVE_PARAMETER_NAMES

<!-- module:version v1.31.1 -->
<!-- module:rule Azure.Deployment.SecureParameter -->

This configuration overrides the default list of parameter names that are considered sensitive.
By setting this configuration option, any parameters names specified are not considered sensitive.

By default, `AZURE_DEPLOYMENT_NONSENSITIVE_PARAMETER_NAMES` is not configured.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_DEPLOYMENT_NONSENSITIVE_PARAMETER_NAMES: array
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_DEPLOYMENT_NONSENSITIVE_PARAMETER_NAMES configuration option
configuration:
  AZURE_DEPLOYMENT_NONSENSITIVE_PARAMETER_NAMES: []
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_DEPLOYMENT_NONSENSITIVE_PARAMETER_NAMES configuration option to enabled
configuration:
  AZURE_DEPLOYMENT_NONSENSITIVE_PARAMETER_NAMES:
    - notSecret
```

### AZURE_DEPLOYMENT_SENSITIVE_PROPERTY_NAMES

<!-- module:version v1.20.0 -->
<!-- module:rule Azure.Deployment.AdminUsername -->

This configuration identifies potentially sensitive properties that should not use hardcoded values.
By setting this configuration option, properties with the specified names will generate a failure when a hardcoded value is detected.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_DEPLOYMENT_SENSITIVE_PROPERTY_NAMES: array
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_DEPLOYMENT_SENSITIVE_PROPERTY_NAMES configuration option
configuration:
  AZURE_DEPLOYMENT_SENSITIVE_PROPERTY_NAMES:
    - adminUsername
    - administratorLogin
    - administratorLoginPassword
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_DEPLOYMENT_SENSITIVE_PROPERTY_NAMES configuration option to enabled
configuration:
  AZURE_DEPLOYMENT_SENSITIVE_PROPERTY_NAMES:
    - adminUsername
    - administratorLogin
    - administratorLoginPassword
    - loginName
```

### AZURE_EVENTGRID_CUSTOM_TOPIC_NAME_FORMAT

<!-- module:version v1.43.0 -->
<!-- module:rule Azure.EventGrid.TopicNaming -->

This configuration option specifies a regular expression that defines the naming format for Azure Event Grid Custom Topics.
When this configuration option is not set, any name is considered valid.

The regular expression used to specify the naming format is case-sensitive by default.
You can use the `(?i)` prefix to make the regular expression case-insensitive.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_EVENTGRID_CUSTOM_TOPIC_NAME_FORMAT: string
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_EVENTGRID_CUSTOM_TOPIC_NAME_FORMAT configuration option
configuration:
  AZURE_EVENTGRID_CUSTOM_TOPIC_NAME_FORMAT: ''
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_EVENTGRID_CUSTOM_TOPIC_NAME_FORMAT configuration option to a specific format
configuration:
  AZURE_EVENTGRID_CUSTOM_TOPIC_NAME_FORMAT: '^evgt-'
```

### AZURE_EVENTGRID_DOMAIN_NAME_FORMAT

<!-- module:version v1.43.0 -->
<!-- module:rule Azure.EventGrid.DomainNaming -->

This configuration option specifies a regular expression that defines the naming format for Azure Event Grid Domains.
When this configuration option is not set, any name is considered valid.

The regular expression used to specify the naming format is case-sensitive by default.
You can use the `(?i)` prefix to make the regular expression case-insensitive.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_EVENTGRID_DOMAIN_NAME_FORMAT: string
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_EVENTGRID_DOMAIN_NAME_FORMAT configuration option
configuration:
  AZURE_EVENTGRID_DOMAIN_NAME_FORMAT: ''
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_EVENTGRID_DOMAIN_NAME_FORMAT configuration option to a specific format
configuration:
  AZURE_EVENTGRID_DOMAIN_NAME_FORMAT: '^evgd-'
```

### AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT

<!-- module:version v1.43.0 -->
<!-- module:rule Azure.EventGrid.SystemTopicNaming -->

This configuration option specifies a regular expression that defines the naming format for Azure Event Grid System Topics.
When this configuration option is not set, any name is considered valid.

The regular expression used to specify the naming format is case-sensitive by default.
You can use the `(?i)` prefix to make the regular expression case-insensitive.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT: string
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT configuration option
configuration:
  AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT: ''
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT configuration option to a specific format
configuration:
  AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT: '^egst-'
```

### AZURE_FIREWALL_IS_ZONAL

<!-- module:version v1.39.0 -->
<!-- module:rule Azure.VNET.FirewallSubnetNAT -->

This configuration identifies if Azure Firewall deployments are expected to be zonal or zone redundant.
Some specific configurations may require Azure Firewall deployed zonal.
If you environment requires a zonal configuration set this to `true` which will toggle rules that apply to this configuration.
By default, `AZURE_FIREWALL_IS_ZONAL` is set to `false`.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_FIREWALL_IS_ZONAL: boolean
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_FIREWALL_IS_ZONAL configuration option
configuration:
  AZURE_FIREWALL_IS_ZONAL: false
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_FIREWALL_IS_ZONAL configuration option to true
configuration:
  AZURE_FIREWALL_IS_ZONAL: true
```

### AZURE_LINUX_OS_OFFERS

<!-- module:version v1.20.0 -->

This configurations specifies names of offers corresponding to the Linux OS.
It's mostly intended to be used when analyzing templates that use private Linux offerings.
Rules that check if a VM or VMSS has Linux OS also validate against the values set by this configuration.

Syntax:

```yaml title="ps-rule.yaml"
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

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_LINUX_OS_OFFERS configuration option to aLinuxOffer, anotherLinuxOffer
configuration:
  AZURE_LINUX_OS_OFFERS:
  - 'aLinuxOffer'
  - 'anotherLinuxOffer'
```

### AZURE_LOAD_BALANCER_NAME_FORMAT

<!-- module:version v1.43.0 -->
<!-- module:rule Azure.LB.Naming -->

This configuration option specifies the naming format for Azure Load Balancers.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_LOAD_BALANCER_NAME_FORMAT: string
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_LOAD_BALANCER_NAME_FORMAT configuration option
configuration:
  AZURE_LOAD_BALANCER_NAME_FORMAT: ''
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_LOAD_BALANCER_NAME_FORMAT configuration option to a specific format
configuration:
  AZURE_LOAD_BALANCER_NAME_FORMAT: 'lb-{name}'
```

### AZURE_POLICY_WAIVER_MAX_EXPIRY

<!-- module:version v1.3.0 -->
<!-- module:rule Azure.Policy.WaiverExpiry -->

This configuration option determines the maximum number of days in the future for a waiver policy exemption.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_POLICY_WAIVER_MAX_EXPIRY: integer
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_POLICY_WAIVER_MAX_EXPIRY configuration option
configuration:
  AZURE_POLICY_WAIVER_MAX_EXPIRY: 366
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_POLICY_WAIVER_MAX_EXPIRY configuration option to 90
configuration:
  AZURE_POLICY_WAIVER_MAX_EXPIRY: 90
```

### AZURE_RESOURCE_ALLOWED_LOCATIONS

<!-- module:version v1.30.0 -->
<!-- module:rule Azure.Resource.AllowedRegions -->

This configuration option specifies a list of allowed locations that resources can be deployed to.
Rules that check the location of Azure resources fail when a resource or resource group is created in a different region.

By default, `AZURE_RESOURCE_ALLOWED_LOCATIONS` is not configured.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_RESOURCE_ALLOWED_LOCATIONS: array # An array of regions
```

Default:

```yaml
# YAML: The default Azure_AllowedRegions configuration option
configuration:
  AZURE_RESOURCE_ALLOWED_LOCATIONS: []
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_RESOURCE_ALLOWED_LOCATIONS configuration option to Australia East, Australia South East
configuration:
  AZURE_RESOURCE_ALLOWED_LOCATIONS:
  - australiaeast
  - australiasoutheast
```

If you configure the `AZURE_RESOURCE_ALLOWED_LOCATIONS` configuration value,
also consider setting `AZURE_RESOURCE_GROUP` the configuration value to when resources use the location of the resource group.

For example:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_RESOURCE_GROUP:
    location: australiaeast
```

### AZURE_RESOURCE_GROUP_NAME_FORMAT

<!-- module:version v1.43.0 -->
<!-- module:rule Azure.Group.Naming -->

This configuration option specifies a regular expression that defines the naming format for Resource Groups.
When this configuration option is not set, any name is considered valid.

The regular expression used to specify the naming format is case-sensitive by default.
You can use the `(?i)` prefix to make the regular expression case-insensitive.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_RESOURCE_GROUP_NAME_FORMAT: string
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_RESOURCE_GROUP_NAME_FORMAT configuration option
configuration:
  AZURE_RESOURCE_GROUP_NAME_FORMAT: ''
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_RESOURCE_GROUP_NAME_FORMAT configuration option to a specific format
configuration:
  AZURE_RESOURCE_GROUP_NAME_FORMAT: '^rg-'
```

### AZURE_STORAGE_DEFENDER_PER_ACCOUNT

<!-- module:version v1.27.0 -->
<!-- module:rule Azure.Storage.DefenderCloud -->

This configuration option enables validation that storage accounts are associated with a resource level Microsoft Defender for Storage plan.
By default, this option is set to `false` because configuration at the subscription level is recommended.
Configure this option to enable the per account validation, which defaults to `false`.

Syntax:

```yaml title="ps-rule.yaml"
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

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_STORAGE_DEFENDER_PER_ACCOUNT configuration option to true
configuration:
  AZURE_STORAGE_DEFENDER_PER_ACCOUNT: true
```

### AZURE_VM_USE_AZURE_HYBRID_BENEFIT

<!-- module:version v1.33.0 -->
<!-- module:rule Azure.VM.UseHybridUseBenefit -->

This configuration option determines whether to check for Azure Hybrid Benefit (AHB) when deploying Windows VMs.
When enabled, rules that check for AHB fail when the VM is not configured to use AHB.

To use AHB, you must separately have eligible licenses, such as Windows Server or SQL Server.

By default, this configuration option is set to `false`.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_VM_USE_AZURE_HYBRID_BENEFIT: boolean
```

Default:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_VM_USE_AZURE_HYBRID_BENEFIT: false
```

Example:

```yaml title="ps-rule.yaml"
# Set the configuration option to enabled.
configuration:
  AZURE_VM_USE_AZURE_HYBRID_BENEFIT: true
```

### AZURE_VM_USE_MULTI_TENANT_HOSTING_RIGHTS

<!-- module:version v1.39.0 -->
<!-- module:rule Azure.VM.MultiTenantHosting -->

This configuration option determines weather to check for Multi-tenant Hosting Rights when deploying Windows VMs.
When enabled, rules that check for MHR fail when a client VM is not configured to use MHR.

By default, this configuration option is set to `false`.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_VM_USE_MULTI_TENANT_HOSTING_RIGHTS: boolean
```

Default:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_VM_USE_MULTI_TENANT_HOSTING_RIGHTS: false
```

Example:

```yaml title="ps-rule.yaml"
# Set the configuration option to enabled.
configuration:
  AZURE_VM_USE_MULTI_TENANT_HOSTING_RIGHTS: true
```

### AZURE_VNET_DNS_WITH_IDENTITY

<!-- module:version v1.30.0 -->
<!-- module:rule Azure.VNET.LocalDNS -->

Set this configuration option to `true` when DNS is deployed within the Identity subscription to avoid false positives.

When deploying Active Directory Domain Services (ADDS) within Azure, you may decide to:

- Deploy an Identity subscription aligned to the Cloud Adoption Framework (CAF) Azure landing zone architecture.
- Host DNS services on the same VMs as ADDS, located in a separate VNET spoke for the Identity subscription.

If you are using this configuration, we recommend you set the configuration option `AZURE_VNET_DNS_WITH_IDENTITY` to `true`.
By default, this configuration option is set to `false`.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_VNET_DNS_WITH_IDENTITY: boolean
```

Default:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_VNET_DNS_WITH_IDENTITY: false
```

Example:

```yaml title="ps-rule.yaml"
# Set the configuration option to enabled.
configuration:
  AZURE_VNET_DNS_WITH_IDENTITY: true
```

### AZURE_VNET_SUBNET_EXCLUDED_FROM_NSG

<!-- module:version v1.33.0 -->
<!-- module:rule Azure.VNET.UseNSGs -->

This configuration option excludes subnets from requiring a Network Security Group (NSG).
You can use this configuration option to exclude subnets that are specific to your environment.
To configure this option, specify a list of subnet names to exclude.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_VNET_SUBNET_EXCLUDED_FROM_NSG: array
```

Default:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_VNET_SUBNET_EXCLUDED_FROM_NSG: []
```

Example:

```yaml title="ps-rule.yaml"
# Configure two customs subnets to be excluded from NSG checks.
configuration:
  AZURE_VNET_SUBNET_EXCLUDED_FROM_NSG:
  - subnet-1
  - subnet-2
```
