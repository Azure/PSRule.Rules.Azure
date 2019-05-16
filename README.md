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

To validate Azure resources running in a subscription, extract the configuration data with the `Export-AzRuleData` cmdlet.

The `Export-AzRuleData` cmdlet exports a resource graph for one or more subscriptions that can be used for analysis with the rules in this module.

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

By default, resource data for all subscriptions will be exported to the current working directory as JSON files; one per subscription.

To limit collection to specific subscriptions use:

- `-Subscription` - to specify subscriptions by id or name.
- `-Tenant` - to specify subscriptions within an Azure Active Directory Tenant by id.

For example:

```powershell
# Export data only from specific subscriptions
Export-AzRuleData -Subscription 'Contoso Production', 'Contoso Non-production'
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
