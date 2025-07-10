---
reviewed: 2025-04-27
title: Setup naming and tagging
author: BernieWhite
---

# Setup naming and tagging

Commonly customers have a set of naming and tagging standards that they want to enforce across their Azure resources.
Using PSRule for Azure, you can enforce these standards from code.

Additionally, you may want to align to the naming and tagging standards of the Cloud Adoption Framework (CAF).
Using the CAF recommendations is not required, but is a good starting point for many customers.

Previously, PSRule for CAF provided a set of rules to enforce naming and tagging standards.
This functionality has been incorporated into PSRule for Azure.
As a part of consolidation, the rules/ configuration/ baselines have been updated to align with PSRule for Azure.
Read _Migrating from PSRule for CAF_ have been included below to help you migrate if you previously used PSRule for CAF.

## Configuring naming format rules

By default, naming format rules are not configured or enforced.
You must configure the naming format rules you want to enforce in your environment.

Azure CAF already provides a set of recommended name prefixes for many Azure resource types.
To accept these recommendations, you can use the built-in CAF baselines prefixed with `Azure.CAF_`.

Alternatively, you can configure the naming format rules to match your own organization's naming standards.

### Setting the naming format for a resource type

To set the naming format for a supported resource type configure the `AZURE_*_NAME_FORMAT` configuration value.
A list of supported resource types and their configuration values is provided at the bottom of this page.

Each name format is configured using a regular expression that is case sensitive by default.
The regular expression is used to match part or the entire the name of the resource.

For example, to set the naming format for a resource group to start with `rg-` use the following configuration:

```yaml
configuration:
  AZURE_RESOURCE_GROUP_NAME_FORMAT: '^rg-'
```

In regular expressions, the `^` character is used to match the start of a string, equivalent to a prefix.
The regular expression is case sensitive.

To create a case insensitive match, use the `(?i)` modifier at the start of the regular expression.
In the following example the `(?i)` modifier is used to allow the resource group name to start with `rg-` or `RG-`.

```yaml
configuration:
  AZURE_RESOURCE_GROUP_NAME_FORMAT: '^(?i)rg-'
```

Similarly, you can use the `$` character to match the end of a string, equivalent to a suffix.

For example, to set the naming format for a resource group to end with `-rg` use the following configuration:

```yaml
configuration:
  AZURE_RESOURCE_GROUP_NAME_FORMAT: '-rg$'
```

To match both the start and end of a string use both `^` and `$`, for example:

```yaml
configuration:
  AZURE_RESOURCE_GROUP_NAME_FORMAT: '^rg-[a-z0-9]{5,10}-(prod|dev|shared)-[0-9]{3}$'
```

### Configuring required tags

To configure required tags use the following configuration values to specify a list of required tags names:

- `AZURE_RESOURCE_GROUP_REQUIRED_TAGS` for resource groups.
- `AZURE_SUBSCRIPTION_REQUIRED_TAGS` for subscription.
- `AZURE_RESOURCE_REQUIRED_TAGS` for all other resources that support tags.

The tag names specified in the configuration values are case sensitive.

Additionally, you can specify a configuration value named with the format `AZURE_TAG_FORMAT_FOR_<TAG_NAME>`.
This configuration value is used to specify the format of the tag value and constrain the value to a specific format.

For example, if you have a tag named `Env`, you can specify the format of the value with the configuration value `AZURE_TAG_FORMAT_FOR_ENV`.

```yaml
configuration:
  AZURE_TAG_FORMAT_FOR_ENV: '^(prod|dev|test)$'
```

!!! Note
    The `AZURE_TAG_FORMAT_FOR_<TAG_NAME>` configuration value allows any required tag to be constrained to a specific value.
    A tag that is not required will not be validated against the format.

    The tag name used in the configuration value should be in upper case, regardless of the case used in the tag.

## Directly adopting CAF recommendations

If you want to directly adopt the CAF recommendations, you can use the latest built-in baseline named with the format `Azure.CAF_yyyy_mm`.
This baseline is a snapshot of a subset of rules supporting the CAF recommendations at the time of release.

If you are starting from scratch, or a new project, consider pinning to the latest baseline when you setup your environment.
New rules and configuration updates are added to the latest baselines.

!!! Note
    Since the CAF recommendations are updated over time, the baseline is versioned with a date.
    It may not be practical for existing resources to align with the latest recommendations when updates are made.
    As changing the name of resources in most cases requires deleting and recreating the resource.
    However, you can supplement a previous baseline by setting naming format configuration values as required.

## Creating custom rules

Today, PSRule for Azure does not provide a naming format rule for every Azure resource type.
If PSRule for Azure does not provide a rule for the resource type you want to enforce a naming format for,
you can [create your own custom rule][1] to supplement the built-in rules.

!!! Tip
    If you feel a key resource type is missing from the built-in rules, please open an [issue on GitHub to request it][2].
    Also, consider creating a custom rule and contributing it back to the project.
    See the [contributing guide][3] for more information.

  [1]: ../customization/enforce-custom-tags.md
  [2]: https://github.com/Azure/PSRule.Rules.Azure/issues/new/choose
  [3]: ../license-contributing/get-started-contributing.md

## Migrating from PSRule for CAF

PSRule for Azure encompasses all the functionality that was previously a standalone module PSRule for CAF.
However, there is some differences in how the rules are configured and run to align with PSRule for Azure.
Additionally, there were some lessons learned from the original PSRule for CAF module that have been incorporated.

Changes from PSRule for CAF to PSRule for Azure include:

- Rules names are now prefixed with `Azure.` instead of `CAF.`.
- All rules now have a stable reference identifier.
- Configuration values are now prefixed with `AZURE_` instead of `CAF_`.
- Previously naming rules only supported setting a name prefix.
  Naming rules now use a regular expression to match the entire name, allowing for prefix, suffix, and middle matching.
- Casing for resource names was case sensitive by default, but all or nothing if it was overridden.
  Now casing is case sensitive by default, but the name format can be overridden on a per resource basis by regular expression.
- Previously the built-in baseline `CAF.Strict` was not versioned however CAF recommended abbreviations changed over time.
  Baselines are now versioned with the `Azure.CAF_` prefix to allow for the CAF recommendations to be updated over time.

What's not changed:

- Consuming suggested abbreviations is still supported by a built-in baseline, and optional.
  Suggested abbreviations are sourced from the Cloud Adoption Framework (CAF).
- Overriding suggested abbreviations is still supported, see the configuration section below.

The following sections, provide details to help you migrate configuration from PSRule for CAF.

### Migrating name prefixes

Configuration values for resource names are configured by a regular expression.

For example:

```yaml
configuration:
  AZURE_RESOURCE_GROUP_NAME_FORMAT: '^rg-'
```

This configuration sets the resource group name to start with `rg-`.
But the resource group name can be anything after the prefix.

Previously this was configured as one or more static prefixes.

```yaml
configuration:
 CAF_ResourceGroupPrefix: [ 'rg-' ]
```

In regular expressions, the `^` character is used to match the start of a string, equivalent to a prefix.
The regular expression is case sensitive.

To create a case insensitive match, use the `(?i)` modifier at the start of the regular expression.

```yaml
configuration:
  AZURE_RESOURCE_GROUP_NAME_FORMAT: '^(?i)rg-'
```

### Migrating required tags

To configure required tags use the following configuration values to specify a list of required tags names:

- `AZURE_RESOURCE_GROUP_REQUIRED_TAGS` for resource groups.
- `AZURE_SUBSCRIPTION_REQUIRED_TAGS` for subscription.
- `AZURE_RESOURCE_REQUIRED_TAGS` for all other resources that support tags.

The tag names specified in the configuration values are case sensitive.

Previously there were configured with a combination of `CAF_ResourceGroupMandatoryTags` and `CAF_ResourceMandatoryTags`.
Additionally, the `CAF_EnvironmentTag` was used to constrain the value of an environment tag.
These previously `CAF_` prefixed configuration values are no longer use.

Instead use the following configuration values to require specific tags such as an environment tag:

```yaml
configuration:
  AZURE_RESOURCE_GROUP_REQUIRED_TAGS: [ 'Env', 'Criticality' ]
  AZURE_RESOURCE_REQUIRED_TAGS: [ 'Env', 'Criticality' ]
```

To constrain the value of a tag use a configuration value named with the format `AZURE_TAG_FORMAT_FOR_<TAG_NAME>`.

For example, to constrain the value of the `Env` tag to be either `prod`, `dev`, or `test` use the following configuration:

```yaml
configuration:
  AZURE_TAG_FORMAT_FOR_ENV: '^(prod|dev|test)$'
```

!!! Note
    The `AZURE_TAG_FORMAT_FOR_<TAG_NAME>` configuration value allows any required tag to be constrained to a specific value.
    A tag that is not required will not be validated against the format.

    The tag name used in the configuration value should be in upper case, regardless of the case used in the tag.

## Supported resource types

The following table lists rules and the resource types they apply to.
To configure the rule for a resource type, set the corresponding configuration value to match the required format.

Rule                                | Resource type                               | Configuration value
----                                | -------------                               | -------------------
`Azure.Search.Naming`               | `Microsoft.Search/searchServices`           | `AZURE_AI_SEARCH_NAME_FORMAT`
`Azure.AI.FoundryNaming`            | `Microsoft.CognitiveServices/accounts` with `kind` = `AIServices`      | `AZURE_AI_SERVICES_NAME_FORMAT`
`Azure.AppInsights.Naming`          | `Microsoft.Insights/components`             | `AZURE_APP_INSIGHTS_NAME_FORMAT`
`Azure.EventGrid.DomainNaming`      | `Microsoft.EventGrid/domains`               | `AZURE_EVENTGRID_DOMAIN_NAME_FORMAT`
`Azure.EventGrid.TopicNaming`       | `Microsoft.EventGrid/topics`, `Microsoft.EventGrid/domains/topics` | `AZURE_EVENTGRID_CUSTOM_TOPIC_NAME_FORMAT`
`Azure.EventGrid.SystemTopicNaming` | `Microsoft.EventGrid/systemTopics`          | `AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT`
`Azure.VNG.ConnectionNaming`        | `Microsoft.Network/connections`             | `AZURE_GATEWAY_CONNECTION_NAME_FORMAT`
`Azure.LB.Naming`                   | `Microsoft.Network/loadBalancers`           | `AZURE_LOAD_BALANCER_NAME_FORMAT`
`Azure.Log.Naming`                  | `Microsoft.OperationalInsights/workspaces`  | `AZURE_LOG_WORKSPACE_NAME_FORMAT`
`Azure.NSG.Naming`                  | `Microsoft.Network/networkSecurityGroups`   | `AZURE_NETWORK_SECURITY_GROUP_NAME_FORMAT`
`Azure.PublicIP.Naming`             | `Microsoft.Network/publicIPAddresses`       | `AZURE_PUBLIC_IP_ADDRESS_NAME_FORMAT`
`Azure.Group.Naming`                | `Microsoft.Resources/resourceGroups`        | `AZURE_RESOURCE_GROUP_NAME_FORMAT`
`Azure.Group.RequiredTags`          | `Microsoft.Resources/resourceGroups`        | `AZURE_RESOURCE_GROUP_REQUIRED_TAGS`
`Azure.Resource.RequiredTags`       | Applies to all types that support tags except subscription and resource groups. | `AZURE_RESOURCE_REQUIRED_TAGS`
`Azure.Route.Naming`                | `Microsoft.Network/routeTables`             | `AZURE_ROUTE_TABLE_NAME_FORMAT`
`Azure.Storage.Naming`              | `Microsoft.Storage/storageAccounts`         | `AZURE_STORAGE_ACCOUNT_NAME_FORMAT`
`Azure.Subscription.RequiredTags`   | `Microsoft.Subscription/aliases`            | `AZURE_SUBSCRIPTION_REQUIRED_TAGS`
`Azure.VM.Naming`                   | `Microsoft.Compute/virtualMachines`         | `AZURE_VIRTUAL_MACHINE_NAME_FORMAT`
`Azure.VNG.Naming`                  | `Microsoft.Network/virtualNetworkGateways`  | `AZURE_VIRTUAL_NETWORK_GATEWAY_NAME_FORMAT`
`Azure.VNET.Naming`                 | `Microsoft.Network/virtualNetworks`         | `AZURE_VNET_NAME_FORMAT`
`Azure.VNET.SubnetNaming`           | `Microsoft.Network/virtualNetworks/subnets` | `AZURE_VNET_SUBNET_NAME_FORMAT`
