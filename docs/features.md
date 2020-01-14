# PSRule for Azure features

The following sections describe key features of PSRule for Azure.

- [Ready to go](#ready-to-go)
- [DevOps](#devops)
- [Cross-platform](#cross-platform)

## Ready to go

PSRule for Azure includes over 80 rules for validating resources against configuration recommendations.
Each rule includes additional information to help remediate validation issues.

Use the built-in rules to start enforcing release processes quickly.
Then layer on your own rules as your organization's requirements mature.
Custom rules can be implemented quickly and work side-by-side with built-in rules.

As new built-in rules are added and improved, download the latest PowerShell module to start using them.

## DevOps

Azure resources can be validated throughout their lifecycle to support a DevOps culture.

From as early as authoring a Azure Resource Manager (ARM) template, resources can be validated offline.
Pre-flight validation can be integrated into a continuous integration (CI) processes to:

- Identify configuration issues and provide fast feedback in a pull request.
- Implement quality gates between environments such as development, test and production.
- Perform ongoing checks for configuration optimization opportunities.

PSRule for Azure provides the following cmdlets that extract data for analysis:

- [Export-AzTemplateRuleData](commands/PSRule.Rules.Azure/en-US/Export-AzTemplateRuleData.md) - Used for pre-flight analysis of one or more ARM templates.
- [Export-AzRuleData](commands/PSRule.Rules.Azure/en-US/Export-AzRuleData.md) - Used for in-flight analysis of resources deployed to one or more Azure subscriptions.

## Cross-platform

PSRule uses modern PowerShell libraries at its core, allowing it to go anywhere Windows PowerShell 5.1 or PowerShell Core 6.2 can go.
PSRule runs on MacOS, Linux and Windows.

To install PSRule for Azure use the `Install-Module` cmdlet within Windows PowerShell or PowerShell Core.

```powershell
Install-Module -Name PSRule.Rules.Azure -Scope CurrentUser;
```

For additional installation options see [install instructions](scenarios/install-instructions.md).

## Frequently Asked Questions (FAQ)

### What permissions do I need to export data?

The default built-in _Reader_ role to a subscription is required for:

- Exporting rule data with `Export-AzRuleData`.
- Exporting rule data from templates with `Export-AzTemplateRuleData` when online features are used.
  - Optionally `-ResourceGroupName` and `-Subscription` parameter can be used, these require access _Reader_ access.

### What permissions do I need to analyze exported data?

No access to Azure is required after data has been exported to JSON.

### Should I continue to use Azure Security Center, Azure Advisor or Azure Policy?

Absolutely.
PSRule for Azure does not replace Azure Security Center, Azure Advisor or Azure Policy.

PSRule complements Azure Security Center, Azure Advisor and Azure Policy features by:

- Recommending turning on and using features of Azure Security Center, Azure Advisor or Azure Policy.
- Providing offline analysis in split environments where the analyst has no access to Azure subscriptions.
  - Rule data for analysis can be exported out to a JSON file.
- Providing the ability to analyze resources in Azure Resource Manager template before deployment.
  - Additionally analysis can be performed in a continuous integration (CI) process.
- Providing the ability to layer on organization specific rules, as required.
- Data collection requires limited permission and requires no additional configuration.
