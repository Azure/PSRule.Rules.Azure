# PSRule for Azure

A suite of rules to validate Azure resources and infrastructure as code (IaC) using PSRule.

[![Open in vscode.dev](https://img.shields.io/badge/Open%20in-vscode.dev-blue)][1]

Features of PSRule for Azure include:

- [Ready to go][2] - Leverage over 260 pre-built rules to validate Azure resources.
- [DevOps][3] - Validate resources and infrastructure code pre or post-deployment.
- [Cross-platform][4] - Run on MacOS, Linux, and Windows.

  [1]: https://vscode.dev/github/Azure/PSRule.Rules.Azure
  [2]: https://azure.github.io/PSRule.Rules.Azure/features/#readytogo
  [3]: https://azure.github.io/PSRule.Rules.Azure/features/#devops
  [4]: https://azure.github.io/PSRule.Rules.Azure/features/#cross-platform

## Project objectives

1. **Ready to go**:
   - Provide a [Azure Well-Architected Framework][5] aligned suite of rules for validating Azure resources.
   - Provide meaningful information to allow remediation.
2. **DevOps**:
   - Resources and templates can be validated before deployment within DevOps workflows.
   - Allow pull request (PR) validation to prevent invalid configuration being merged.
3. **Enterprise ready**:
   - Rules can be directly adopted and additional enterprise specific rules can be layed on.
   - Provide regular baselines to allow progressive adoption.

  [5]: https://docs.microsoft.com/en-gb/azure/architecture/framework/

## Support

This project uses GitHub Issues to track bugs and feature requests.
Before logging an issue please see our [troubleshooting guide].

Please search the existing issues before filing new issues to avoid duplicates.

- For new issues, file your bug or feature request as a new [issue].
- For help, discussion, and support questions about using this project, join or start a [discussion].

If you have any problems with the [PSRule][engine] engine, please check the project GitHub [issues](https://github.com/Microsoft/PSRule/issues) page instead.

Support for this project/ product is limited to the resources listed above.

## Getting the modules

This project requires the `PSRule` and `Az` PowerShell modules. For details on each see [install].

You can download and install these modules from the PowerShell Gallery.

Module             | Description | Downloads / instructions
------             | ----------- | ------------------------
PSRule.Rules.Azure | Validate Azure resources and infrastructure as code using PSRule. | [latest][module] / [instructions][install]

## Getting started

PSRule for Azure provides two methods for analyzing Azure resources:

- _Pre-flight_ - Before resources are deployed from Azure Resource Manager templates.
- _In-flight_ - After resources are deployed to an Azure subscription.

For specific use cases see [scenarios](#scenarios).
For additional details see the [FAQ](https://azure.github.io/PSRule.Rules.Azure/faq/).

### Using with GitHub Actions

The following example shows how to setup GitHub Actions to validate templates pre-flight.

1. See [Creating a workflow file][create-workflow].
2. Reference `Microsoft/ps-rule` with `modules: 'PSRule.Rules.Azure'`.

For example:

```yaml
# Example: .github/workflows/analyze-arm.yaml

#
# STEP 1: Template validation
#
name: Analyze templates
on:
  push:
    branches:
    - main
  pull_request:
    branches:
    - main
jobs:
  analyze_arm:
    name: Analyze templates
    runs-on: ubuntu-latest
    steps:

    - name: Checkout
      uses: actions/checkout@v3

    # STEP 2: Run analysis against exported data
    - name: Analyze Azure template files
      uses: microsoft/ps-rule@v2.1.0
      with:
        modules: 'PSRule.Rules.Azure'  # Analyze objects using the rules within the PSRule.Rules.Azure PowerShell module.
```

### Using with Azure Pipelines

The following example shows how to setup Azure Pipelines to validate templates pre-flight.

1. Install [PSRule extension][extension] for Azure DevOps marketplace.
2. Create a new YAML pipeline with the _Starter pipeline_ template.
3. Add the `Install PSRule module` task.
   - Set module to `PSRule.Rules.Azure`.
4. Add the `PSRule analysis` task.
   - Set input type to `repository`.
   - Set modules to `PSRule.Rules.Azure`.

For example:

```yaml
# Example: .azure-pipelines/analyze-arm.yaml

#
# STEP 2: Template validation
#
jobs:
- job: 'analyze_arm'
  displayName: 'Analyze templates'
  pool:
    vmImage: 'ubuntu-20.04'
  steps:

  # STEP 3: Install PSRule.Rules.Azure from the PowerShell Gallery
  - task: ps-rule-install@2
    displayName: Install PSRule.Rules.Azure
    inputs:
      module: 'PSRule.Rules.Azure'   # Install PSRule.Rules.Azure from the PowerShell Gallery.

  # STEP 4: Run analysis against exported data
  - task: ps-rule-assert@2
    displayName: Analyze Azure template files
    inputs:
      modules: 'PSRule.Rules.Azure'   # Analyze objects using the rules within the PSRule.Rules.Azure PowerShell module.
```

### Using locally

The following example shows how to setup PSRule locally to validate templates pre-flight.

1. Install the `PSRule.Rules.Azure` module and dependencies from the PowerShell Gallery.
2. Run analysis against repository files.

For example:

```powershell
# STEP 1: Install PSRule.Rules.Azure from the PowerShell Gallery
Install-Module -Name 'PSRule.Rules.Azure' -Scope CurrentUser;

# STEP 2: Run analysis against exported data
Assert-PSRule -Module 'PSRule.Rules.Azure' -InputPath 'out/templates/' -Format File;
```

### Export in-flight resource data

The following example shows how to setup PSRule locally to validate resources running in a subscription.

1. Install the `PSRule.Rules.Azure` module and dependencies from the PowerShell Gallery.
2. Connect and set context to an Azure subscription from PowerShell.
3. Export the resource data with the `Export-AzRuleData` cmdlet.
4. Run analysis against exported data.

For example:

```powershell
# STEP 1: Install PSRule.Rules.Azure from the PowerShell Gallery
Install-Module -Name 'PSRule.Rules.Azure' -Scope CurrentUser;

# STEP 2: Authenticate to Azure, only required if not currently connected
Connect-AzAccount;

# Confirm the current subscription context
Get-AzContext;

# STEP 3: Exports a resource graph stored as JSON for analysis
Export-AzRuleData -OutputPath 'out/templates/';

# STEP 4: Run analysis against exported data
Assert-PSRule -Module 'PSRule.Rules.Azure' -InputPath 'out/templates/';
```

### Additional options

By default, resource data for the current subscription context will be exported.

To export resource data for specific subscriptions use:

- `-Subscription` - to specify subscriptions by id or name.
- `-Tenant` - to specify subscriptions within an Azure Active Directory Tenant by id.

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

- `-All` - to export resource data for all subscription contexts.

For example:

```powershell
# Export data from all subscription contexts
Export-AzRuleData -All;
```

To filter results to only failed rules, use `Invoke-PSRule -Outcome Fail`.
Passed, failed and error results are shown by default.

For example:

```powershell
# Only show failed results
Invoke-PSRule -InputPath 'out/templates/' -Module 'PSRule.Rules.Azure' -Outcome Fail;
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
Invoke-PSRule -InputPath 'out/templates/' -Module 'PSRule.Rules.Azure' -As Summary;
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

## Scenarios

For walk through examples of PSRule for Azure module usage see:

- [Validate Azure resources from templates with Azure Pipelines](docs/scenarios/azure-pipelines-ci/azure-pipelines-ci.md)
- [Validate Azure resources from templates with continuous integration (CI)](docs/scenarios/azure-template-ci/azure-template-ci.md)
- [Create a custom rule to enforce Resource Group tagging](https://azure.github.io/PSRule.Rules.Azure/customization/enforce-custom-tags/)
- [Create a custom rule to enforce code ownership](https://azure.github.io/PSRule.Rules.Azure/customization/enforce-codeowners/)

## Rule reference

PSRule for Azure includes rules across five pillars of the [Microsoft Azure Well-Architected Framework][5].

- [Rules for architecture excellence](https://azure.github.io/PSRule.Rules.Azure/en/rules/module/)
  - [Cost Optimization](https://azure.github.io/PSRule.Rules.Azure/en/rules/module/#costoptimization)
  - [Operational Excellence](https://azure.github.io/PSRule.Rules.Azure/en/rules/module/#operationalexcellence)
  - [Performance Efficiency](https://azure.github.io/PSRule.Rules.Azure/en/rules/module/#performanceefficiency)
  - [Reliability](https://azure.github.io/PSRule.Rules.Azure/en/rules/module/#reliability)
  - [Security](https://azure.github.io/PSRule.Rules.Azure/en/rules/module/#security)

To view a list of rules by Azure resources see:

- [Rules by resource](https://azure.github.io/PSRule.Rules.Azure/en/rules/resource/)

## Baseline reference

The following baselines are included within `PSRule.Rules.Azure`.

- [Azure.Default](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.Default/) - Default baseline for Azure rules.
- [Azure.All](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.All/) - Includes all Azure rules.
- [Azure.GA_2020_06](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.GA_2020_06/) - Baseline for GA rules released June 2020 or prior.
- [Azure.GA_2020_09](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.GA_2020_09/) - Baseline for GA rules released September 2020 or prior.
- [Azure.GA_2020_12](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.GA_2020_12/) - Baseline for GA rules released December 2020 or prior.
- [Azure.GA_2021_03](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.GA_2021_03/) - Baseline for GA rules released March 2021 or prior.
- [Azure.GA_2021_06](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.GA_2021_06/) - Baseline for GA rules released June 2021 or prior.
- [Azure.GA_2021_09](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.GA_2021_09/) - Baseline for GA rules released September 2021 or prior.
- [Azure.GA_2021_12](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.GA_2021_12/) - Baseline for GA rules released December 2021 or prior.
- [Azure.GA_2022_03](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.GA_2022_03/) - Baseline for GA rules released March 2022 or prior.
- [Azure.Preview](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.Preview/) - Includes rules for Azure GA and preview features.
- [Azure.Preview_2021_09](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.Preview_2021_09/) - Baseline for rules released September 2021 or prior for Azure preview only features.
- [Azure.Preview_2021_12](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.Preview_2021_12/) - Baseline for rules released December 2021 or prior for Azure preview only features.
- [Azure.Preview_2022_03](https://azure.github.io/PSRule.Rules.Azure/en/baselines/Azure.Preview_2022_03/) - Baseline for rules released March 2022 or prior for Azure preview only features.

## Language reference

PSRule for Azure extends PowerShell with the following cmdlets.

### Commands

PSRule for Azure included the following cmdlets:

- [Export-AzRuleData](docs/commands/Export-AzRuleData.md) - Export resource configuration data from Azure subscriptions.
- [Export-AzRuleTemplateData](docs/commands/Export-AzRuleTemplateData.md) - Export resource configuration data from Azure templates.
- [Export-AzPolicyAssignmentData](docs/commands/Export-AzPolicyAssignmentData.md) - Export policy assignment data.
- [Export-AzPolicyAssignmentRuleData](docs/commands/Export-AzPolicyAssignmentRuleData.md) - Export JSON based rules from policy assignment data.
- [Get-AzRuleTemplateLink](docs/commands/Get-AzRuleTemplateLink.md) - Get a metadata link to a Azure template file.
- [Get-AzPolicyAssignmentDataSource](docs/commands/Get-AzPolicyAssignmentDataSource.md) - Get policy assignment sources.

## Concepts

To find out more, look at these conceptual topics:

- Getting started:
  - [Creating your pipeline](https://azure.github.io/PSRule.Rules.Azure/creating-your-pipeline/)
  - [Validating locally](https://azure.github.io/PSRule.Rules.Azure/validating-locally/)
- Testing infrastructure as code:
  - [Expanding source files](https://azure.github.io/PSRule.Rules.Azure/expanding-source-files/)
  - [Using templates](https://azure.github.io/PSRule.Rules.Azure/using-templates/)
  - [Using Bicep source](https://azure.github.io/PSRule.Rules.Azure/using-bicep/)
  - [Working with baselines](https://azure.github.io/PSRule.Rules.Azure/working-with-baselines/)
- Setup:
  - [Configuring options](https://azure.github.io/PSRule.Rules.Azure/setup/configuring-options/)
  - [Configuring rule defaults](https://azure.github.io/PSRule.Rules.Azure/setup/configuring-rules/)
  - [Configuring expansion](https://azure.github.io/PSRule.Rules.Azure/setup/configuring-expansion/)
  - [Setup Bicep](https://azure.github.io/PSRule.Rules.Azure/setup/setup-bicep/)
  - [Setup Azure Monitor logs](https://azure.github.io/PSRule.Rules.Azure/setup/setup-azure-monitor-logs/)

## Related projects

The following projects can also be used with PSRule for Azure.

Name                      | Description
----                      | -----------
[PSRule.Rules.CAF]        | A suite of rules to validate Azure resources against the Cloud Adoption Framework (CAF) using PSRule.
[PSRule.Monitor]          | Send and query PSRule analysis results in Azure Monitor.
[PSRule-pipelines]        | An Azure DevOps extension for using PSRule within Azure Pipelines.
[ps-rule]                 | Validate infrastructure as code (IaC) and DevOps repositories using GitHub Actions.

## Changes and versioning

This repository uses [semantic versioning](http://semver.org/) to declare breaking changes.
For a list of module changes please see the [change log](CHANGELOG.md).

> Pre-release module versions are created on major commits and can be installed from the PowerShell Gallery.
> Pre-release versions should be considered experimental.
> Modules and change log details for pre-releases will be removed as standard releases are made available.

## Contributing

This project welcomes contributions and suggestions.
If you are ready to contribute, please visit the [contribution guide](CONTRIBUTING.md).

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Maintainers

- [Bernie White](https://github.com/BernieWhite)
- [Armaan Mcleod](https://github.com/ArmaanMcleod)

## License

This project is [licensed under the MIT License](LICENSE).

[issue]: https://github.com/Azure/PSRule.Rules.Azure/issues
[discussion]: https://github.com/Azure/PSRule.Rules.Azure/discussions
[install]: https://azure.github.io/PSRule.Rules.Azure/install-instructions/
[module]: https://www.powershellgallery.com/packages/PSRule.Rules.Azure
[engine]: https://github.com/Microsoft/PSRule
[PSRule.Rules.CAF]: https://github.com/microsoft/PSRule.Rules.CAF
[PSRule.Monitor]: https://github.com/microsoft/PSRule.Monitor
[PSRule-pipelines]: https://github.com/microsoft/PSRule-pipelines
[ps-rule]: https://github.com/microsoft/ps-rule
[create-workflow]: https://help.github.com/en/articles/configuring-a-workflow#creating-a-workflow-file
[extension]: https://marketplace.visualstudio.com/items?itemName=bewhite.ps-rule
[troubleshooting guide]: https://azure.github.io/PSRule.Rules.Azure/troubleshooting/
