---
author: BernieWhite
---

# Using templates

PSRule for Azure discovers and analyzes Azure resources contained within template and parameter files.
To enable this feature, you need to:

1. Enable expansion.
2. Link parameter files to templates.

!!! Abstract
    This topic covers how you can validate Azure resources within template `.json` files.
    To learn more about why this is important see [Expanding source files](expanding-source-files.md).

## Enabling expansion

To expand parameter files configure `ps-rule.yaml` with the `AZURE_PARAMETER_FILE_EXPANSION` option.

```yaml title="ps-rule.yaml"
# YAML: Enable expansion for template expansion.
configuration:
  AZURE_PARAMETER_FILE_EXPANSION: true
```

After enabling expansion, PSRule for Azure will start to discover ARM templates and Bicep module from parameter files.
Supported parameter files must:

- The use `.parameters.json` or `.parameters.jsonc` suffix. i.e. `deploy.parameters.jsonc`.
- The use either of the following schemas:
  - `https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#` OR
  - `https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#`
- Must be linked to a template or Bicep module using one of the methods described below.

## Linking templates

PSRule for Azure automatically detects parameter files and uses the following logic to link templates or Bicep modules.

- **By metadata** &mdash; Check parameter file for a metadata link identifying the associated template.
- **By naming convention** &mdash; Check for matching template files using file naming convention.

!!! Note
    Metadata links take priority over naming convention.
    For details on both options continue reading.

!!! Tip
    Linking templates also applies to Bicep modules when you are using JSON parameter files.

### By metadata

A parameter file can be linked to an associated template or Bicep module by setting metadata.
To link a template within a parameter file, set the `metadata.template` property to the path of the template.

PSRule for Azure supports either:

- **Relative to repository** &mdash; By default, the path is relative to the root of the repository.
- **Relative to template** &mdash; To use a path relative to the parameter file,
  prefix the path with `./`.

!!! Tip
    Referencing a path outside of the repository is blocked as this could lead to unintended exposure.

=== "Relative to repository"

    The following example shows linking to a template which is stored within a hierarchical `template/` sub-directory.

    !!! Example

        ```json
        {
            "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
            "contentVersion": "1.0.0.0",
            "metadata": {
                "template": "templates/storage/v1/template.json"
            },
            "parameters": {
            }
        }
        ```

=== "Relative to parameter file"

    The following example shows linking to a template that is in the same directory as the parameter file.

    !!! Example

        ```json
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

Additional benefits you get by using metadata links include:

- You can share a common set of versioned templates across multiple deployments in a repository.
  This works great to mono-repositories.
- You can discover all the deployments using a specific template by reading metadata.
  PSRule for Azure includes the `Get-AzRuleTemplateLink` cmdlet to list parameter file links.

!!! Tip
    By default, metadata links are not required.
    By configuring the `AZURE_PARAMETER_FILE_METADATA_LINK` option to `true`, this can be enforced.
    When configured, PSRule for Azure will fail parameter files that do not contain a metadata link.
    For details on `AZURE_PARAMETER_FILE_METADATA_LINK` see [Configuring expansion][2].

!!! Note
    Bicep modules can also be expanded from parameter files.
    Instead of specifying a template path, you can specify the path to a Bicep file.

!!! Note
    You may find while editing a `.json` parameter file the root `metadata` property is flagged with a warning.
    For example `Property metadata is not allowed.`.
    This doesn't affect the workings of the parameter file or deployment.
    If you like a detailed description continue reading [Troubleshooting][9].

  [2]: setup/configuring-expansion.md#require-template-metadata-link
  [9]: troubleshooting.md

### By naming convention

When metadata links are not set, PSRule will fallback to use a naming convention to link to template files.

!!! Example
    A parameter file named `azuredeploy.parameters.json` links to the template file named `azuredeploy.json`.

PSRule for Azure supports linking by naming convention when:

- Parameter files end with `.parameters.json` or `.parameters.jsonc` linking to ARM templates or Bicep modules.
- The parameter file prefix matches the file name of the template or Bicep module.
  For example, `azuredeploy.parameters.json` links to `azuredeploy.json`, `azuredeploy.jsonc`, or `azuredeploy.bicep`.
- Both parameter file and template or Bicep module must be in the same directory.
- The following search order is used to determine the file that will be used if multiple template or Bicep files exist:
  1. ARM template file with the `.json` extension.
  2. ARM template file with the `.jsonc` extension.
  3. Bicep module file with the `.bicep` extension.

For example, `azuredeploy.parameters.json` links to `azuredeploy.json` over `azuredeploy.jsonc` or `azuredeploy.bicep`.
When `azuredeploy.json` does not exist, `azuredeploy.jsonc` is chosen.
Finally `azuredeploy.parameters.json` will link to `azuredeploy.bicep` if neither of the other files exist.

The following is not currently supported:

- Using a different naming convention for parameter files such as `<templateName>.param.json`.
- Template or parameter files with alternative file extensions such as `.jsonc`.

*[WAF]: Well-Architected Framework
*[ARM]: Azure Resource Manager
*[CI]: continuous integration
*[PR]: Pull Request
