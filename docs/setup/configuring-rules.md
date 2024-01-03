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

  [1]: configuring-options.md

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
  AZURE_AKS_CLUSTER_MINIMUM_VERSION: 1.27.7
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the AZURE_AKS_CLUSTER_MINIMUM_VERSION configuration option to 1.22.4
configuration:
  AZURE_AKS_CLUSTER_MINIMUM_VERSION: 1.22.4
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

### AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST

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

### Set the minimum MaxPods for a node pool

<!-- module:version v1.0.0 -->

This configuration option determines the minimum allowed max pods setting per node pool.
When an AKS cluster node pool is created, a `maxPods` option is used to determine the maximum number of pods for each node in the node pool.

Depending on your workloads it may make sense to change this option:

- Micro-services/ web applications: 50+
- Data movement/ processing: 20-30

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  Azure_AKSNodeMinimumMaxPods: integer
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default Azure_AKSNodeMinimumMaxPods configuration option
configuration:
  Azure_AKSNodeMinimumMaxPods: 50
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Set the Azure_AKSNodeMinimumMaxPods configuration option to 30
configuration:
  Azure_AKSNodeMinimumMaxPods: 30
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

### Azure_MinimumCertificateLifetime

This configuration option determines the minimum number of days allowed before certificate expiry.
Rules that check certificate lifetime fail when the days remaining before expiry drop below this number.

Syntax:

```yaml title="ps-rule.yaml"
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

```yaml title="ps-rule.yaml"
# YAML: Set the Azure_MinimumCertificateLifetime configuration option to 90
configuration:
  Azure_MinimumCertificateLifetime: 90
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

### AZURE_POLICY_IGNORE_LIST

<!-- module:version v1.21.0 -->

This configuration option configures a custom list policy definitions to ignore when exporting policy to rules.
In addition to the custom list, a built-in list of policies are ignored.
The built-in list can be found [here](https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/policy-ignore.json).

Configure this option to ignore policy definitions that:

- Already have a rule defined.
- Are not relevant to testing Infrastructure as Code.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_POLICY_IGNORE_LIST: array
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_POLICY_IGNORE_LIST configuration option
configuration:
  AZURE_POLICY_IGNORE_LIST: []
```

Example:

```yaml title="ps-rule.yaml"
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

```yaml title="ps-rule.yaml"
configuration:
  AZURE_POLICY_RULE_PREFIX: string
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_POLICY_RULE_PREFIX configuration option
configuration:
  AZURE_POLICY_RULE_PREFIX: Azure
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Override the prefix of exported policy rules
  AZURE_POLICY_RULE_PREFIX: AzureCustomPrefix
```

### AZURE_POLICY_WAIVER_MAX_EXPIRY

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

### AZURE_STORAGE_DEFENDER_PER_ACCOUNT

<!-- module:version v1.27.0 -->
<!-- module:rule Azure.Storage.DefenderCloud -->

This configuration option enables validation for that each storage account is associated with a Microsoft Defender for Storage resource level plan.
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
  AZURE_VNET_DNS_WITH_IDENTITY: true
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
