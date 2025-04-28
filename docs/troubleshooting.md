---
author: BernieWhite
discussion: false
description: Error messages and troubleshooting steps for resolving common issues with PSRule for Azure.
---

# Troubleshooting

This article provides troubleshooting instructions for common errors.

## Bicep compile errors

When expanding Bicep source files you may get an error including a _BCPnnn_ code similar to the following:

!!! Message

    Exception calling "GetResources" with "3" argument(s): "Bicep (0.14.46) compilation of '<file>' failed with: Error BCP057: The name "storageAccountName" does not exist in the current context.

This error is raised when the Bicep CLI fails to compile a source file.
To resolve this issue:

- You may need to update your Bicep source file before PSRule can expand it.
  Use guidance from the Bicep error message to help resolve the issue.
- If the error message is not clear, the Bicep documentation may help you understand the error.
  A list of Bicep diagnostic codes is available at [Bicep core diagnostics][15].
- Check that you are using a version of Bicep that supports the Bicep features you are using.
  It may not always be clear which version of Bicep CLI that PSRule for Azure is using if you have multiple versions installed.
  For example:
  - GitHub Actions and Azure DevOps may use a different version of Bicep CLI than your local machine.
  - The version of the Bicep CLI installed by the Azure CLI may be different from the standalone Bicep CLI.

!!! Note
    Using the Bicep CLI managed by the Azure CLI (`az bicep`) is not the default,
    and you may need to [set additional options to use it][7].

!!! Tip
    From PSRule for Azure v1.25.0 you can configure the minimum version of Bicep CLI required.
    If an earlier version is detected, PSRule for Azure will generate an error.
    See [Configuring minimum version][8] for details on how to configure this option.

  [7]: setup/setup-bicep.md#using-azure-cli
  [8]: setup/setup-bicep.md#configuring-minimum-version
  [15]: https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-core-diagnostics

## Bicep version

When expanding Bicep source files you may get an error relating to the Bicep version you have installed.
For example if you attempt to use a Bicep feature that is not supported by the version used by PSRule for Azure.

Check the Bicep version reported by PSRule supports the Bicep features you are using.

PSRule for Azure uses the Bicep CLI installed on your machine or CI worker.
By default, the Bicep CLI binary will be selected by your `PATH` environment variable.

Optionally you can configure an alternative Bicep CLI binary to use by either:

- **By path** &mdash; Set the [PSRULE_AZURE_BICEP_PATH][9] environment variable to the specified binary path.
- **From Azure CLI** &mdash; Set the [PSRULE_AZURE_BICEP_USE_AZURE_CLI][10] environment variable to `true`.

For more details on installing and configuring the Bicep CLI, see [Setup Bicep][11].

  [9]: setup/setup-bicep.md#setting-environment-variables
  [10]: setup/setup-bicep.md#using-azure-cli
  [11]: setup/setup-bicep.md

## Bicep features

Generally PSRule for Azure plans to support any language features that are supported by the latest version of Bicep.
New language features are often added behind an experimental feature flag for community feedback.
Features flagged by Bicep as experimental may not be supported by PSRule for Azure immediately.
PSRule for Azure will plan to add support as soon as possible after the feature flag is removed.

If you are using a Bicep feature that is not supported by PSRule for Azure, please [join or start a discussion][4].

  [4]: https://github.com/Azure/PSRule.Rules.Azure/discussions

## Bicep compilation timeout

When expanding Bicep source files you may get an error similar to the following:

!!! Message

    Bicep (0.4.1124) compilation of 'C:\temp\deploy.bicep' failed with: Bicep compilation hasn't completed within the timeout window. This can be caused by errors or warnings. Check the Bicep output by running bicep build and addressing any issues.

This error is raised when Bicep takes longer then the timeout to build a source file.
The default timeout is 5 seconds.

You can take steps to reduce your code complexity and reduce the time a build takes by:

- Removing unnecessary nested `module` calls.
- Cache bicep modules restored from a registry in continuous integration (CI) pipelines.

To increase the timeout value, set the `AZURE_BICEP_FILE_EXPANSION_TIMEOUT` configuration option.
See [Bicep compilation timeout][1] for details on how to configure this option.

  [1]: setup/configuring-expansion.md#bicep-compilation-timeout

## No rules or no Azure resources are found

There is a few common causes of this issue including:

- **Check input format** &mdash; PSRule for Azure must discover files to expand them.
  - When running PSRule for Azure using GitHub Actions or the Azure Pipelines extension:
    - Your pipeline **must** be set to `inputType: repository`, which is the default value.
    - PSRule for Azure will not work with `inputType` set to `inputPath`.
    - You may have set this parameter because you wanted to use the `inputPath` parameter.
      Setting the `inputType` is not a requirement for using the `inputPath` parameter.
      The `inputPath` parameter can be used independently.
  - When running PSRule for Azure from PowerShell:
    - Your command-line **must** use the `-Format File` parameter.
    - Your command-line **must** use the `-InputPath` or `-f` parameter followed by a file or directory path.
    - For example: `Assert-PSRule -Module PSRule.Rules.Azure -Format File -f 'modules/'`.
- **Check expansion is enabled** &mdash; Expansion must be enabled to analyze Azure Infrastructure as Code.
  See [using templates][2] and [using Bicep source][3] for details on how to enable expansion.
- **Check parameter files are linked** &mdash; Parameter files must be linked to ARM templates or Bicep source files.
  See [using templates][2] for details on how to link using metadata or naming convention.

!!! Note
    If your pipeline is still not finding any Azure resources, please [join or start a discussion][4].

  [2]: using-templates.md
  [3]: using-bicep.md

## Custom rules are not running

There is a few common causes of this issue including:

- **Check rule path** &mdash; By default, PSRule will look for rules in the `.ps-rule/` directory.
  This directory is the root for your repository or the current working path by default.
  On case-sensitive file systems such as Linux, this directory name is case-sensitive.
  See [Storing and naming rules][5] for more information.
- **Check file name suffix** &mdash; PSRule only looks for files with the `.Rule.ps1`, `.Rule.yaml`, or `.Rule.jsonc` suffix.
  On case-sensitive file systems such as Linux, this file suffix is case-sensitive.
  See [Storing and naming rules][5] for more information.
- **Check binding configuration** &mdash; PSRule uses _binding_ to work out which property to use for a resource type.
  To be able to use the `-Type` parameter or `type` properties in rules definitions, binding must be set.
  This is automatically configured for PSRule for Azure, however must be set in `ps-rule.yaml` for custom rules.
  See [binding type][6] for more information.
- **Check modules** &mdash; PSRule for Azure is responsible for expanding Azure resources from Infrastructure as Code.
  Expansion occurs automatically in memory when enabled.
  For this to work, the module `PSRule.Rules.Azure` must be run with any custom rules.
  See [using templates][2] and [using Bicep source][3] for details on how to enable expansion.
- **Check include local option** &mdash; When running PSRule for Azure with a baseline.
  Baselines such as [quarterly baselines][12] may use filters to limit the rules that are included.
  As a result, custom rules may not be included.
  To include custom rules set the [Rule.IncludeLocal][13] option to `true`.
  See [Including custom rules][14] for more information.

!!! Tip
    You may be able to use `git mv` to change the case of a file if it is committed to the repository incorrectly.

  [5]: https://aka.ms/ps-rule/naming
  [6]: customization/using-custom-rules.md#set-binding-configuration
  [12]: working-with-baselines.md#quarterly-baseline
  [13]: https://aka.ms/ps-rule/options#ruleincludelocal
  [14]: working-with-baselines.md#including-custom-rules

## Parameter file warns of metadata property

You may find while editing a `.json` parameter file the root `metadata` property is flagged with a warning.

!!! Message

    The property 'metadata' is not allowed.

```json title="Azure parameter file" hl_lines="4"
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "./storage.template.json"
    },
    "parameters": {
    }
}
```

This doesn't affect the workings of the parameter file or deployment.
The reason for the warning is that the `metadata` property has not been added to the parameter file JSON schema.
However, the top level `metadata` property is ignored by Azure Resource Manager when deploying a template.

## Issues with Az.Resources

The PowerShell module `Az.Resources` and `Az.Accounts` is currently used when exporting data from Azure.
These modules are use when:

- Exporting resources for in-flight analysis.
- Exporting policy assignments for policy as rules.

These modules are not required if you only want to execute rules.

### Suppression of Az.Resources warning

If you only intend to execute rules you can suppress the following warning message.

!!! Message

    To use PSRule for Azure export cmdlets please install Az.Resources.

This message can be ignored if you are not exporting data from Azure.
To suppress the warning configure the `PSRULE_AZURE_RESOURCE_MODULE_NOWARN` environment variable to `true`.
For more details see [Configuring exports](setup/configuring-exports.md#psrule_azure_resource_module_nowarn).

### Installing Az.Resources

If you plan on exporting data from Azure, you must install the `Az.Resources` module.

Some versions of `Az.Resources` are known to be incompatible with PSRule for Azure.
As a result, we recommend installing and importing v6.7.0 to address these issues.
A known incompatibility currently exists with v7.1.0 ([#2970](https://github.com/Azure/PSRule.Rules.Azure/issues/2970)).
By default, PowerShell will attempt to install or use a newer version already installed which may return an error.

!!! Message

    ExpandPolicyAssignment: The property 'Properties' cannot be found on this object. Verify that the property exists.

To install a specific version use:

```powershell title="PowerShell"
Install-Module Az.Resources -RequiredVersion '6.7.0' -Force -Scope CurrentUser
```

To import a specific version prior to using PSRule:

```powershell title="PowerShell"
Import-Module Az.Resources -RequiredVersion '6.7.0'
```

## Could not load file or assembly YamlDotNet

PSRule **>=1.3.0** uses an updated version of the YamlDotNet library.
The PSRule for Azure **<1.3.1** uses an older version of this library which may conflict.

To avoid this issue:

- Update to the latest version and use PSRule for Azure **>=1.3.1** with PSRule **>=1.3.0**.
- Alternatively, when using PSRule for Azure **<1.3.1** use PSRule **=1.2.0**.

To install the latest module version of PSRule use the following commands:

```powershell title="PowerShell"
Install-Module -Name PSRule.Rules.Azure -MinimumVersion 1.3.1 -Scope CurrentUser -Force;
```

For the PSRule GitHub Action, use **>=1.4.0**.

```yaml title="GitHub Actions"
- name: Run PSRule analysis
  uses: microsoft/ps-rule@v2.9.0
```

## PFA0001: Unable to process the deployment

!!! Message

    PFA0001: Unable to process the deployment because the template requested a failure. See https://aka.ms/ps-rule-azure/troubleshooting.

This error is returned when the template or Bicep module called the `fail()` function.
A template or Bicep module author may call the `fail()` function to cause a validation error.

If you got this message, continue reading to the end of the message to see the details of the validation error set by author.
