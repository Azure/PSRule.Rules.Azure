---
author: BernieWhite
---

# Storing custom rules

PSRule for Azure covers common use cases that align to the [Microsoft Azure Well-Architected Framework (WAF)][1].
In addition to WAF alignment you may have a requirement to enforce organization specific rules.

For example:

- Required tags on a resource group.
- Code ownership for sensitive resource types.

PSRule allows custom rules to be layered on.
These custom rules work side-by-side with PSRule for Azure.

  [1]: https://learn.microsoft.com/azure/well-architected/

## Using a standard file path

Rules can be standalone or packaged within a module.
Standalone rules are ideal for a single project such as an Infrastructure as Code (IaC) repository.
To reuse rules across multiple projects consider packaging these as a module.

The instructions for packaging rules in a module can be found here:

- [Packaging rules in a module][2]

To store standalone rules we recommend that you:

- **Use .ps-rule/** &mdash; Create a sub-directory called `.ps-rule` in the root of your repository.
  Use all lower-case in the sub-directory name.
  Put any custom rules within this sub-directory.
- **Use files ending with .Rule.ps1** &mdash; PSRule uses a file naming convention to discover rules.
  We recommend using a file name that ends in `.Rule.ps1`.

!!! note
    Build pipelines are often case-sensitive or run on Linux-based systems.
    Using the casing rule above reduces confusion latter when you configure continuous integration (CI).

  [2]: https://microsoft.github.io/PSRule/stable/authoring/packaging-rules/

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
