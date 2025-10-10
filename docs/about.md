---
author: BernieWhite
discussion: false
---

# What is PSRule for Azure?

PSRule for Azure is a pre-built set of tests and documentation to help you configure Azure solutions.
These tests allow you to check your Infrastructure as Code (IaC) before or after deployment to Azure.
PSRule for Azure includes unit tests that check how Azure resources defined in ARM templates or Bicep code are configured.

## Why use PSRule for Azure?

PSRule for Azure helps you identify changes to improve the quality of solutions deployed on Azure.
PSRule for Azure uses the principles of the Azure Well-Architected Framework (WAF) to:

- **Suggest changes** &mdash; you can use to improve the quality of your solution.
- **Link to documentation** &mdash; to learn how this applies to your environment.
- **Demonstrate** &mdash; how you can implement the change with examples.
  Examples are provided in Azure Bicep and ARM templates syntax.

If you want to write your own tests, you can do that too in your choice of YAML, JSON, or PowerShell.
However with over 490 tests already built, you can identify and fix issues day one.

!!! Learn "Get started with a sample repository"
    To get started with a sample repository, see [PSRule for Azure Quick Start][1] on GitHub.

  [1]: https://github.com/Azure/PSRule.Rules.Azure-quickstart

## Introducing PSRule for Azure

An introduction to PSRule for Azure and how it relates to the Azure Well-Architected Framework.
We also give an quick overview of baselines, handling exceptions, and reporting options.

<iframe width="560" height="315" src="https://www.youtube.com/embed/L4CIDqnXLPk" title="YouTube - Introducing PSRule for Azure" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

## Who uses PSRule for Azure?

Several first-party repositories use PSRule for Azure.
Here's a few you may be familiar with:

- [Azure/bicep-registry-modules](https://aka.ms/brm) - Azure Verified Modules (AVM) (Bicep)
- [Azure/ResourceModules](https://github.com/Azure/ResourceModules) - Common Azure Resource Modules Library
- [Azure/ALZ-Bicep](https://github.com/Azure/ALZ-Bicep) - Azure Landing Zones (ALZ)
- [Azure/AKS-Construction](https://github.com/Azure/AKS-Construction) - AKS Construction

*[IaC]: Infrastructure as Code
*[ARM]: Azure Resource Manager
