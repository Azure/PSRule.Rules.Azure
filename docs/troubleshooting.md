---
author: BernieWhite
discussion: false
---

# Troubleshooting

This article provides troubleshooting instructions for common errors.

## Bicep compile errors

When expanding Bicep source files you may get an error including a _BCPnnn_ code similar to the following:

!!! Error

    Exception calling "GetResources" with "3" argument(s): "Bicep (0.14.46) compilation of '<file>' failed with: Error BCP057: The name "storageAccountName" does not exist in the current context.

This error is raised when Bicep fails to compile a source file.
To resolve this issue:

- You may need to update your Bicep source file before PSRule can expand it.
  Use guidance from the Bicep error message to help resolve the issue.
- Check that you are using a version of Bicep that supports the Bicep features you are using.
  It may not always be clear which version of Bicep CLI PSRule for Azure is using if you have multiple versions installed.
  Using the Bicep CLI via `az bicep` is not the default, and you may need to [set additional options to use it][7].

!!! Tip
    From PSRule for Azure v1.25.0 you can configure the minimum version of Bicep CLI required.
    If an earlier version is detected, PSRule for Azure will generate an error.
    See [Configuring minimum version][8] for details on how to configure this option.

  [7]: setup/setup-bicep.md#using-azure-cli
  [8]: setup/setup-bicep.md#configuring-minimum-version

## Bicep version

When expanding Bicep source files you may get an error relating to the Bicep version you have installed.
For example if you attempt to use a Bicep feature that is not supported by the version used by PSRule for Azure.

PSRule for Azure uses the Bicep CLI installed on your machine or CI worker.
By default, the Bicep CLI binary will be selected by your `PATH` environment variable.

Optionally you can configure an alternative Bicep CLI binary to use by either:

- **By path** &mdash; Set the [PSRULE_AZURE_BICEP_PATH][9] environment variable to the specified binary path.
- **From Azure CLI** &mdash; Set the [PSRULE_AZURE_BICEP_USE_AZURE_CLI][10] environment variable to `true`.

For more details on installing and configuring the Bicep CLI, see [Setup Bicep][11].

  [9]: setup/setup-bicep.md#setting-environment-variables
  [10]: setup/setup-bicep.md#using-azure-cli
  [11]: setup/setup-bicep.md

## Bicep compilation timeout

When expanding Bicep source files you may get an error similar to the following:

!!! Error

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
  [4]: https://github.com/Azure/PSRule.Rules.Azure/discussions

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

!!! Tip
    You may be able to use `git mv` to change the case of a file if it is committed to the repository incorrectly.

  [5]: https://aka.ms/ps-rule/naming
  [6]: customization/enforce-custom-tags.md#binding-type

## Parameter file warns of metadata property

You may find while editing a `.json` parameter file the root `metadata` property is flagged with a warning.

!!! Warning

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

## An earlier version of Az.Accounts is imported

When running PSRule for Azure in Azure DevOps within the `AzurePowerShell@5` task,
you may see the following error.

!!! Error

    This module requires Az.Accounts version 2.8.0. An earlier version of
    Az.Accounts is imported in the current PowerShell session. Please open a new
    session before importing this module. This error could indicate that multiple
    incompatible versions of the Azure PowerShell cmdlets are installed on your
    system. Please see https://aka.ms/azps-version-error for troubleshooting
    information.

This error is raised by a chained dependency failure importing a newer version of `Az.Accounts`.
To avoid this issue attempt to install the exact versions of `Az.Resources`.
In the `AzurePowerShell@5` task before installing PSRule.

```powershell
Install-Module Az.Resources -RequiredVersion '5.6.0' -Force -Scope CurrentUser
```

From PSRule for Azure v1.16.0, `Az.Accounts` and `Az.Resources` are no longer installed as dependencies.
When using export commands from PSRule, you may need to install these modules.

To install these modules, use the following PowerShell command:

```powershell
Install-Module Az.Resources -Force -Scope CurrentUser
```

## Could not load file or assembly YamlDotNet

PSRule **>=1.3.0** uses an updated version of the YamlDotNet library.
The PSRule for Azure **<1.3.1** uses an older version of this library which may conflict.

To avoid this issue:

- Update to the latest version and use PSRule for Azure **>=1.3.1** with PSRule **>=1.3.0**.
- Alternatively, when using PSRule for Azure **<1.3.1** use PSRule **=1.2.0**.

To install the latest module version of PSRule use the following commands:

```powershell
Install-Module -Name PSRule.Rules.Azure -MinimumVersion 1.3.1 -Scope CurrentUser -Force;
```

For the PSRule GitHub Action, use **>=1.4.0**.

```yaml
- name: Run PSRule analysis
  uses: microsoft/ps-rule@v2.8.0
```
