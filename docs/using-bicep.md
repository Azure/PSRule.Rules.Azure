---
author: BernieWhite
---

# Using Bicep source

PSRule for Azure also supports analyzing Azure resources contained within Bicep source files.

!!! Experimental
    Support for Bicep source files is currently an experimental feature.
    It is not recommended for production use.
    Please give us [feedback] on this feature and report any [issues] you encounter.

!!! Abstract
    This topic covers how to use use PSRule for Azure to validate Azure resources within Bicep source.

## Source file expansion

Bicep source files provide an additional option to define Azure resources.
Bicep provides a abstraction layer on top of Azure Resource Manager (ARM) that is more human readable.
When Azure resources are built from Bicep source files, an ARM template is generated.
PSRule for Azure automates this in memory to allow analysis of Azure resources from `.bicep` files.

### Feature support

Expansion of Azure resources contained within Bicep source files is supported.
For details on how this works and limitations see [Using templates][1].

In addition, currently the following limitation apply to using Bicep source files:

- The Bicep CLI must be installed.
- PSRule for Azure will only expand Bicep source files without mandatory parameters.
  To modules with mandatory parameters you can [exclude files by path spec][2].
  Expand from a `main.bicep` that is intended to be deployed directly to Azure.
- Location of issues in Bicep source files is not supported.
- Expansion of Bicep source files times out after 5 seconds.

  [1]: using-templates.md#featuresupport
  [2]: setup/configuring-expansion.md#excludingfiles

### Setup Bicep

To expand Azure resources for analysis from Bicep source files the Bicep CLI is required.
For details on how to configure Bicep for PSRule for Azure see [Setup Bicep][3].

  [3]: setup/setup-bicep.md

*[WAF]: Well-Architected Framework
*[ARM]: Azure Resource Manager

[feedback]: https://github.com/Azure/PSRule.Rules.Azure/discussions
[issues]: https://github.com/Azure/PSRule.Rules.Azure/issues
