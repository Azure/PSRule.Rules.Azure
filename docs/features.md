---
author: BernieWhite
---

# Features

## Framework aligned

PSRule for Azure is aligned to the [Azure Well-Architected Framework (WAF)][2].
Tests called _rules_ check the configuration of Azure resources against WAF principles.
Rules exist across five (5) WAF pillars:

- Cost Optimization
- Operational Excellence
- Performance Efficiency
- Reliability
- Security

To help you align your Infrastructure as Code (IaC) to WAF principles, PSRule for Azure includes documentation.
Included are examples, references to WAF and product documentation.
This allows you to explore and learn the context of each WAF principle.

  [1]: https://microsoft.github.io/PSRule/
  [2]: https://docs.microsoft.com/azure/architecture/framework/

## Ready to go

PSRule for Azure includes over 280 rules for validating resources against configuration recommendations.
Rules automatically detect and analyze resources from Azure IaC artifacts.
This allows you to quickly light up unit testing of Azure resources from templates and Bicep deployments.

Use the built-in rules to start enforcing testing quickly.
Then layer on your own rules as your organization's requirements mature.
Custom rules can be implemented quickly and work side-by-side with built-in rules.

As new built-in rules are added and improved, download the latest version to start using them.

!!! Tip
    For detailed information on building custom rules see:

    - [Enforcing custom tags][3].
    - [Enforcing code ownership][3].

  [3]: customization/enforce-custom-tags.md
  [4]: customization/enforce-codeowners.md

## DevOps integrated

Azure resources can be validated throughout their lifecycle to support a DevOps culture.
From as early as authoring an ARM template, resources can be validated offline before deployment.

Pre-flight validation can be integrated into a continuous integration (CI) pipeline as unit tests to:

- **Shift-left** &mdash; Identify configuration issues and provide fast feedback in PRs.
- **Quality gates** &mdash; Implement quality gates between environments such as dev, test, and production.
- **Monitor continuously** &mdash; Perform ongoing checks for configuration optimization opportunities.

## Cross-platform

PSRule for Azure uses modern PowerShell libraries at its core,
allowing it to go anywhere PowerShell can go.
PSRule for Azure runs on MacOS, Linux, and Windows.

PowerShell makes it easy to integrate PSRule into popular CI systems.
Run natively or in a container depending on your platform.
PSRule has native extensions for:

- [Azure Pipelines (Azure DevOps)][5]
- [GitHub Actions][6]
- [Visual Studio Code][7]

Additionally, PSRule for Azure can be installed locally or within Azure Cloud Shell.
For installation options see [installation][8].

  [5]: https://marketplace.visualstudio.com/items?itemName=bewhite.ps-rule
  [6]: https://github.com/marketplace/actions/psrule
  [7]: https://marketplace.visualstudio.com/items?itemName=bewhite.psrule-vscode
  [8]: install-instructions.md

*[ARM]: Azure Resource Manager
*[WAF]: Well-Architected Framework
*[IaC]: Infrastructure as Code
*[CI]: Continuous Integration
*[PRs]: Pull Requests
