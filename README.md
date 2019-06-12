# PSRule for Azure

A suite of rules to validate Azure resources using PSRule.

![ci-badge]

## Disclaimer

This project is to be considered a **proof-of-concept** and **not a supported product**.

For issues with rules and documentation please check our GitHub [issues](https://github.com/BernieWhite/PSRule.Rules.Azure/issues) page. If you do not see your problem captured, please file a new issue and follow the provided template.

If you have any problems with the [PSRule][engine] engine, please check the project GitHub [issues](https://github.com/BernieWhite/PSRule/issues) page instead.

## Getting the modules

This project requires the `PSRule` and `Az` PowerShell modules. For details on each see [install].

You can download and install these modules from the PowerShell Gallery.

Module             | Description | Downloads / instructions
------             | ----------- | ------------------------
PSRule.Rules.Azure | Validate Azure resources | [latest][module] / [instructions][install]

## Getting started

### Export resource data

To validate Azure resources running in a subscription, export the resource data with the `Export-AzRuleData` cmdlet.

The `Export-AzRuleData` cmdlet exports a resource graph for one or more subscriptions that can be used for analysis with the rules in this module.

By default, resources for the current subscription context are exported. See below for more options.

Before running this command you should connect to Azure by using the `Connect-AzAccount` cmdlet.

For example:

```powershell
# Authenticate to Azure, only required if not currently connected
Connect-AzAccount;

# Export resource data
Export-AzRuleData;
```

### Validate resources

To validate Azure resources use the extracted data with the `Invoke-PSRule` cmdlet.

For example:

```powershell
Invoke-PSRule -InputPath .\*.json -Module 'PSRule.Rules.Azure';
```

### Additional options

By default, resource data for the current subscription context will be exported to the current working directory as JSON.

To export resource data for specific subscriptions use:

- `-Subscription` - to specify subscriptions by id or name.
- `-Tenant` - to specify subscriptions within an Azure Active Directory Tenant by id.

For example:

```powershell
# Export data from specific subscriptions
Export-AzRuleData -Subscription 'Contoso Production', 'Contoso Non-production'
```

To export resource data for all subscription contexts use:

- `-All` - to export resource data for all subscription contexts.

For example:

```powershell
# Export data from all subscription contexts
Export-AzRuleData -All;
```

To filter results to only failed rules, use `Invoke-PSRule -Outcome Fail`. Passed, failed and error results are shown by default.

For example:

```powershell
# Only show failed results
Invoke-PSRule -InputPath .\*.json -Module 'PSRule.Rules.Azure' -Outcome Fail;
```

The output of this example is:

```text
   TargetName: storage

RuleName                            Outcome    Recommendation
--------                            -------    --------------
Azure.Storage.UseReplication        Fail       Storage accounts not using GRS may be at risk
Azure.Storage.SecureTransferRequ... Fail       Storage accounts should only accept secure traffic
Azure.Storage.SoftDelete            Fail       Enable soft delete on Storage Accounts
```

A summary of results can be displayed by using `Invoke-PSRule -As Summary`.

For example:

```powershell
# Display as summary results
Invoke-PSRule -InputPath .\*.json -Module 'PSRule.Rules.Azure' -As Summary;
```

The output of this example is:

```text
RuleName                            Pass  Fail  Outcome
--------                            ----  ----  -------
Azure.ACR.MinSku                    0     1     Fail
Azure.AppService.PlanInstanceCount  0     1     Fail
Azure.AppService.UseHTTPS           0     2     Fail
Azure.Resource.UseTags              73    36    Fail
Azure.SQL.ThreatDetection           0     1     Fail
Azure.SQL.Auditing                  0     1     Fail
Azure.Storage.UseReplication        1     7     Fail
Azure.Storage.SecureTransferRequ... 2     6     Fail
Azure.Storage.SoftDelete            0     8     Fail
```

## Rule reference

The following rules are included in the `PSRule.Rules.Azure` module:

- [PSRule.Rules.Azure](docs/rules/en-US/Azure.md)

## Language reference

PSRule.Rules.Azure extends PowerShell the following cmdlets.

### Commands

The following commands exist in the `PSRule.Rules.Azure` module:

- [Export-AzRuleData](docs/commands/PSRule.Rules.Azure/en-US/Export-AzRuleData.md) - Export resource configuration data from one or more Azure subscriptions.

## Changes and versioning

Modules in this repository will use the [semantic versioning](http://semver.org/) model to declare breaking changes from v1.0.0. Prior to v1.0.0, breaking changes may be introduced in minor (0.x.0) version increments. For a list of module changes please see the [change log](CHANGELOG.md).

> Pre-release module versions are created on major commits and can be installed from the PowerShell Gallery. Pre-release versions should be considered experimental. Modules and change log details for pre-releases will be removed as standard releases are made available.

## Maintainers

- [Bernie White](https://github.com/BernieWhite)

## License

This project is [licensed under the MIT License](LICENSE).

[install]: docs/scenarios/install-instructions.md
[ci-badge]: https://dev.azure.com/bewhite/PSRule.Rules.Azure/_apis/build/status/PSRule.Rules.Azure-CI?branchName=master
[module]: https://www.powershellgallery.com/packages/PSRule.Rules.Azure
[engine]: https://github.com/BernieWhite/PSRule
