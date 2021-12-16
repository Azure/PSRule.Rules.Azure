---
author: BernieWhite
---

# Using templates

PSRule for Azure discovers and analyzes Azure resources contained within template and parameter files.
To enable this feature, you need to:

- Enable expansion.
- Link parameter files to templates.

!!! Abstract
    This topic covers how you can validate Azure resources within template `.json` files.
    To learn more about why this is important see [Expanding source files](expanding-source-files.md).

## Enabling expansion

To expand parameter files configure `ps-rule.yaml` with the `AZURE_PARAMETER_FILE_EXPANSION` option.

```yaml
# YAML: Enable expansion for template expansion.
configuration:
  AZURE_PARAMETER_FILE_EXPANSION: true
```

## Linking templates

PSRule for Azure automatically detects parameter files and uses the following logic to link templates.

- **By metadata** &mdash; Check parameter file for a metadata link identifying the associated template.
- **By naming convention** &mdash; Check for matching template files using file naming convention.

!!! Note
    Metadata links take priority over naming convention.
    For details on both options continue reading.

### By metadata

A parameter file can be linked to an associated template by setting metadata.
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

  [2]: setup/configuring-expansion.md#requiretemplatemetadatalink

### By naming convention

When metadata links are not set, PSRule for Azure will use a naming convention to link to template files.
PSRule for Azure uses the parameter file prefix `<templateName>.parameters.json` to link to a template.
When linking using naming convention, the template and the parameter file must be in the same sub-directory.

!!! Example
    A parameter file named `azuredeploy.parameters.json` links to the template file named `azuredeploy.json`.

*[WAF]: Well-Architected Framework
*[ARM]: Azure Resource Manager
*[CI]: continuous integration
*[PR]: Pull Request
