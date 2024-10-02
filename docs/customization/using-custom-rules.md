---
description: This topic covers how you can use custom rules to test Azure Infrastructure as Code.
author: BernieWhite
---

# Using custom rules

PSRule for Azure covers common use cases that align to the [Microsoft Azure Well-Architected Framework (WAF)][1].
In addition to WAF alignment you may have a requirement to enforce organization specific rules.

For example:

- Required tags on a resource group.
- Code ownership for sensitive resource types.
- Apply similar controls to Infrastructure as Code that are deployed via Azure Policies.

PSRule allows custom rules to be layered on.
These custom rules work side-by-side with PSRule for Azure.

  [1]: https://learn.microsoft.com/azure/well-architected/

!!! Abstract
    This topic covers how you can use custom rules to test Azure Infrastructure as Code (IaC).

## Requirements

For custom rules to work with IaC the following requirements must be configured:

1. Set a binding configuration.
2. Configure expansion for processing Bicep or ARM templates.
3. Include the `PSRule.Rules.Azure` module.

### Set binding configuration

Rules packaged within PSRule for Azure will automatically detect Azure resources by their type properties.
Standalone rules will get their type binding configuration from `ps-rule.yaml` instead.
When binding is not configured, custom rules will typically be ignored.

To configure type binding:

- Create/ update the `ps-rule.yaml` file within the root of the repository.
- Add the following configuration snippet.

```yaml title="ps-rule.yaml"
# Configure binding options
binding:
  targetType:
    - 'resourceType'
    - 'type'
```

### Configuring expansion

PSRule for Azure performs [expansion][2] on Bicep and ARM template files it finds in your repository.
Enabling expansion is required for testing any IaC in your repository.
The requirements for custom rules are no different then using the built-in rules included within PSRule for Azure.

To configure expansion see either:

- [Using Bicep source](../using-bicep.md)
- [Using templates](../using-templates.md)

  [2]: ../faq.md#what-is-expansion

### Including PSRule for Azure

When creating custom rules to test Azure IaC including PSRule for Azure is required for most scenarios.
PSRule for Azure performs [expansion][2] on Bicep and ARM template files it finds in your repository.

You can include PSRule for Azure by specifying `PSRule.Rules.Azure` in one of the following:

- **Pipeline** &mdash; The `modules:` parameter in [GitHub Actions or Azure Pipelines][3].
- **PowerShell** &mdash; The `-Module` parameter with the [PowerShell cmdlets][4].
- **Options** &mdash; - The `Include.Module` [option][5].

  [3]: ../creating-your-pipeline.md
  [4]: ../creating-your-pipeline.md
  [5]: https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Options/#includemodule

## Using a standard file path

Rules can be standalone or packaged within a module.
Standalone rules are ideal for a single project such as an Infrastructure as Code (IaC) repository.
To reuse rules across multiple projects consider packaging these as a module.

The instructions for packaging rules in a module can be found here:

- [Packaging rules in a module][6]

To store standalone rules we recommend that you:

- **Use .ps-rule/** &mdash; Create a sub-directory called `.ps-rule` in the root of your repository.
  Use all lower-case in the sub-directory name.
  Put any custom rules within this sub-directory.
- **Use files ending with .Rule.ps1 | .Rule.yaml | .Rule.jsonc** &mdash;
  PSRule uses a file naming convention to discover rules.
  We recommend using a file name that ends in `.Rule.ps1` or `.Rule.yaml` or `.Rule.jsonc`.

!!! note
    Build pipelines are often case-sensitive or run on Linux-based systems.
    Using the casing rule above reduces confusion latter when you configure continuous integration (CI).

  [6]: https://microsoft.github.io/PSRule/stable/authoring/packaging-rules/

## Naming rules

When running PSRule, rule names must be unique.
PSRule for Azure uses the name prefix of `Azure.` on all rules and resources included in the module.

!!! example
    The following names are examples of rules included within PSRule for Azure:

    - `Azure.AKS.Version`
    - `Azure.AKS.AuthorizedIPs`
    - `Azure.SQL.MinTLS`

When naming custom rules we recommend that you:

- **Use a standard prefix** &mdash; You can use the `Local.` or `Org.` prefix for standalone rules.
  - Alternatively choose a short prefix that identifies your organization.
- **Use dotted notation** &mdash; Use dots to separate rule name.
- **Use a maximum length of 35 characters** &mdash; The default view of `Invoke-PSRule` truncates longer names.
  PSRule supports longer rule names however if `Invoke-PSRule` is called directly consider using `Format-List`.

## Related content

- [Using Bicep source](../using-bicep.md)
- [Using templates](../using-templates.md)
- [Creating your pipeline](creating-your-pipeline.md)

*[IaC]: Azure Resource Manager
