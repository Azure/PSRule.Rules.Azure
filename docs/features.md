---
author: BernieWhite
---

# What is PSRule for Azure?

PSRule for Azure is a module for [PSRule][1], a flexible rules engine designed to validate Infrastructure as Code (IaC).
PSRule for Azure includes a suite [Azure Well-Architected Framework (WAF)][AWAF] aligned rules for validating Azure resources.

Leverage over 200 pre-built rules across five (5) WAF pillars:

- Cost Optimization
- Operational Excellence
- Performance Efficiency
- Reliability
- Security

Rules automatically detect and analyzes Azure resources from IaC artifacts,
such as Azure Resource Manager (ARM) templates.

PSRule for Azure supports two methods for analyzing Azure resources:

- **Pre-flight** &mdash; Before resources are deployed from an ARM template.
  Use _pre-flight_ analysis to:
  - Implement checks within Pull Requests (PRs).
  - Improve alignment of resources to WAF recommendations.
  - Identify issues that prevent successful resource deployments on Azure.
  - Implement release gates between environments.
- **In-flight** &mdash; After resource are deployed to an Azure subscription.
  Use _in-flight_ analysis to:
  - Implement release gates between environments for non-native tools such as Terraform.
  - Performing offline analysis in split-environments.

  [1]: https://microsoft.github.io/PSRule/
  [AWAF]: https://docs.microsoft.com/azure/architecture/framework/

## Ready to go

PSRule for Azure includes over 200 rules for validating resources against configuration recommendations.
Each rule includes additional information to help remediate issues.

Use the built-in rules to start enforcing release processes quickly.
Then layer on your own rules as your organization's requirements mature.
Custom rules can be implemented quickly and work side-by-side with built-in rules.

As new built-in rules are added and improved, download the latest version to start using them.

!!! Tip
    For detailed information on building custom rules see:

    - [Enforcing custom tags][3].

  [3]: customization/enforce-custom-tags/index.md

## DevOps

Azure resources can be validated throughout their lifecycle to support a DevOps culture.
From as early as authoring an ARM template, resources can be validated offline before deployment.

Pre-flight validation can be integrated into a continuous integration (CI) pipeline to:

- **Shift-left** &mdash; Identify configuration issues and provide fast feedback in PRs.
- **Quality gates** &mdash; Implement quality gates between environments such as development, test, and production.
- **Monitor continuously** &mdash; Perform ongoing checks for configuration optimization opportunities.

<!-- PSRule for Azure provides the following cmdlets that extract data for analysis:

- [Export-AzRuleTemplateData](commands/Export-AzRuleTemplateData.md) - Used for pre-flight analysis of one or more ARM templates.
- [Export-AzRuleData](commands/Export-AzRuleData.md) - Used for in-flight analysis of resources deployed to one or more Azure subscriptions. -->

## Cross-platform

PSRule for Azure uses modern PowerShell libraries at its core,
allowing it to go anywhere PowerShell can go.
PSRule for Azure runs on MacOS, Linux, and Windows.

PowerShell makes it easy to integrate PSRule into popular CI systems.
Run natively or in a container depending on your platform.
PSRule has native extensions for:

- [Azure Pipelines (Azure DevOps)][4]
- [GitHub Actions][5]
- [Visual Studio Code][6]

Additionally, PSRule for Azure can be installed locally or within Azure Cloud Shell.
For installation options see [installation][7].

  [4]: https://marketplace.visualstudio.com/items?itemName=bewhite.ps-rule
  [5]: https://github.com/marketplace/actions/psrule
  [6]: https://marketplace.visualstudio.com/items?itemName=bewhite.psrule-vscode
  [7]: install-instructions.md

## Frequently Asked Questions (FAQ)

Continue reading for FAQ relating to _PSRule for Azure_.
For general FAQ see [PSRule - Frequently Asked Questions (FAQ)][ps-rule-faq], including:

- [How is PSRule different to Pester?][compare-pester]
- [How do I configure PSRule?][ps-rule-configure]
- [How do I ignore a rule?][ignore-rule]

### Do I need PowerShell experience to start using PSRule for Azure?

No. You can start using built-in rules and CI with Azure Pipelines or GitHub Actions.
If we didn't tell you, you might not even know that PowerShell runs under the covers.

To perform local validation, some PowerShell setup is required but we step you through that.
See [installation][7] and [validating locally][8] for details.

To start writing your own custom rules, some PowerShell experience is required.
We have a walk through scenario [Enforcing custom tags][9] to get you started.

  [8]: validating-locally.md
  [9]: customization/enforce-custom-tags/index.md

### What permissions do I need to export data?

The default built-in _Reader_ role to a subscription is required for:

- Exporting rule data with `Export-AzRuleData`.
- Exporting rule data from templates with `Export-AzRuleTemplateData` when online features are used.
  - Optionally `-ResourceGroupName` and `-Subscription` parameter can be used; these require access _Reader_ access.

### What permissions do I need to analyze exported data?

When exporting data for _in-flight_ analysis,
no access to Azure is required after data has been exported to JSON.

### Should I continue to use Azure Advisor, Security Center, or Azure Policy?

Absolutely.
PSRule for Azure does not replace Azure Advisor, Security Center, or Azure Policy.

PSRule complements Azure Advisor, Security Center, and Azure Policy features by:

- Recommending turning on and using features of Azure Advisor, Azure Security Center, or Azure Policy.
- Providing offline analysis in split environments where the analyst has no access to Azure subscriptions.
  Rule data for analysis can be exported out to a JSON file.
- Providing the ability to analyze resources in Azure Resource Manager templates before deployment.
  Additionally, analysis can be performed in a CI process.
- Providing the ability to layer on organization specific rules, as required.
- Data collection requires limited permissions and requires no additional configuration.

### Traditional unit testing vs PSRule for Azure?

You may already be using a unit test framework such as Pester to test infrastructure code.
If you are, then you may have encountered the following challenges.

For a general PSRule/ Pester comparison see [How is PSRule different to Pester?][compare-pester]

#### Unit testing more than basic JSON structure

Unit tests are unable to effectively test resources contained within Azure templates.
Templates should be reusable, but this creates problems for testing when functions, conditions and copy loops are used.
Template parameters could completely change the type, number of, or configuration of resources.

PSRule resolves templates to allow analysis of the resources that would be deployed based on provided parameters.

#### Standard library of tests

When building unit tests for Azure resources, starting with an empty repository can be a daunting experience.
While there are several open source repositories and samples around to get you started, you need to integrate these yourself.

_PSRule for Azure_ is distributed as a PowerShell module using the PowerShell Gallery.
Using a PowerShell module makes it easy to install and update.
The built-in rules allow you starting testing resources quickly, with minimal integration.

For detailed examples see:

- [Validate Azure resources from templates with Azure Pipelines](scenarios/azure-pipelines-ci/azure-pipelines-ci.md)
- [Validate Azure resources from templates with continuous integration (CI)](scenarios/azure-template-ci/azure-template-ci.md)

### Collection of telemetry

PSRule and PSRule for Azure currently do not collect any telemetry during installation or execution.

PowerShell (used by PSRule for Azure) does collect basic telemetry by default.
Collection of telemetry in PowerShell and how to opt-out is explained in [about_Telemetry][10].

  [10]: https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_telemetry

*[ARM]: Azure Resource Manager
*[WAF]: Well-Architected Framework
*[IaC]: Infrastructure as Code
*[CI]: Continuous Integration
*[PRs]: Pull Requests

[compare-pester]: https://github.com/microsoft/PSRule/blob/main/docs/features.md#how-is-psrule-different-to-pester
[ignore-rule]: https://github.com/microsoft/PSRule/blob/main/docs/features.md#how-do-i-ignore-a-rule
[ps-rule-configure]: https://github.com/microsoft/PSRule/blob/main/docs/features.md#how-do-i-configure-psrule
[ps-rule-faq]: https://github.com/microsoft/PSRule/blob/main/docs/features.md#frequently-asked-questions-faq
