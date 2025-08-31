---
author: BernieWhite
---

# Exporting rule data

The current state of Azure resources can be tested with PSRule for Azure, referred to as _in-flight_ analysis.
This is a two step process that works in high security environments with separation of roles.

!!! Abstract
    This topics covers how you can export the current state of Azure resources deployed into a subscription.
    After the current state has been exported, offline analysis can be performed against the saved state.

!!! Important
    Before continuing, complete the steps from [Installing locally][1].
    To export data from a subscription, Azure PowerShell modules must be installed.
    Exporting rule data can also be automated and scheduled with Azure Automation Service.
    However, for this scenario we will focus how to run this process interactively.

To perform analysis on Azure resources the current configuration state is exported to a JSON file format.
The exported state is processed later during analysis.

- **What's exported** &mdash; Configurations such as:
  - Resource SKUs, names, tags, and settings configured for an Azure resource.
  - Optionally, security alerts can be exported from Microsoft Defender for Cloud.
- **What's not exported** &mdash; Resource data such as:
  - The contents of blobs stored on a storage account, or databases tables.

  [1]: install.md#installing-locally

## Export an Azure subscription

The state of resources from the current Azure subscription will be exported by using the following commands:

```powershell
# STEP 1: Authenticate to Azure, only required if not currently connected
Connect-AzAccount;

# STEP 2: Confirm the current subscription context
Get-AzContext;

# STEP 3: Exports Azure resources to JSON files
Export-AzRuleData -OutputPath 'out/';
```

!!! Important
    There are known issues with different versions of the Azure PowerShell modules.
    The recommended versions of `Az.Accounts` module are:

    - `Az.Accounts` &mdash; `3.0.x` ... `5.1.x`

    If you are using a different version, you may encounter issues with the export process.
    If you have multiple version of the Azure PowerShell modules installed, you can ensure the correct version is used by:

    - Starting a new PowerShell session.
    - Importing the specific version of the module you want to use.
      For example:

      ```powershell
      Import-Module Az.Accounts -RequiredVersion 5.1.0;
      ```

### Additional options

By default, resource data for the current subscription context will be exported.

To export resource data for specific subscriptions use:

- `-Subscription` - to specify subscriptions by id or name.
- `-Tenant` - to specify subscriptions within an Entra ID tenant id.

For example:

```powershell
# Export data from two specific subscriptions
Export-AzRuleData -Subscription 'Contoso Production', 'Contoso Non-production';
```

To export specific resource data use:

- `-ResourceGroupName` - to filter resources by Resource Group.
- `-Tag` - to filter resources based on tag.

For example:

```powershell
# Export information from two resource groups within the current subscription context
Export-AzRuleData -ResourceGroupName 'rg-app1-web', 'rg-app1-db';
```

To export resource data for all subscription contexts use:

- `-All` - to export resource data for all available subscription contexts.

For example:

```powershell
# Export data from all subscription contexts
Export-AzRuleData -All;
```

!!! Note
    By default, `Connect-AzAccount` loads a maximum of 25 subscriptions contexts.
    If more than 25 subscriptions are available, specify `-MaxContextPopulation` to increase the limit.
    See [Connect-AzAccount](https://learn.microsoft.com/powershell/module/az.accounts/connect-azaccount#-maxcontextpopulation)
    for more information.

To export security alerts from Microsoft Defender for Cloud for the subscription use:

- `-ExportSecurityAlerts` - to export active security alerts from Microsoft Defender for Cloud.
  When this option is specified, active security alerts that are high or medium severity will be exported.

For example:

```powershell
# Export security alerts from the specified subscription
Export-AzRuleData -Subscription 'Contoso Production' -ExportSecurityAlerts;
```
