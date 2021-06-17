---
author: BernieWhite
---

# Using metadata

PSRule for Azure detects Azure template and parameter files in your repository based on their schemas.
This provides template and parameter file linting for structure and general usage.

!!! Abstract
    This topic covers how to use metadata to improve the success of Azure deployments.

## Parameter file expansion

In additional to template and parameter file linting,
PSRule for Azure can automatically resolve template and parameter file context at runtime.
Resolved context provides some unique benefits such as:

- **As deployed** &mdash; Analysis of Azure resources as if they are deployed.
  - Parameters, conditional resources, functions (built-in and user defined), variables,
    and copy loops are resolved.
  - Azure resource names are shown in passing and failing results.
    Resolving issues with resource configurations can be targeted by resource.
  - Resource file locations for template and parameter files are included in results.
- **Unassigned parameters** &mdash; Detection of missing mandatory parameters.
  - Increases success of deployments by finding these errors earlier such as within a PR.
- **Suppression by resource name** &mdash; Azure resource names can be used to apply exceptions.
  - Suppression allows for individual resources to be excluded from rules by name.

To get these benefits, Azure parameter files must be associated to templates.
PSRule for Azure uses links to achieve this.

!!! Note
    Azure parameter file expansion needs to be enabled.
    It is not enabled by default to preserve the default behavior prior to PSRule for Azure v1.4.0.
    [Creating your pipeline][1] covers how to enable this in a CI pipeline.

## Template links

PSRule for Azure automatically detects parameter files and uses the following logic to associate templates.

- **By metadata** &mdash; Check parameter file for a metadata link identifying the associated template.
- **By naming convention** &mdash; Check for matching template files using file naming convention.

!!! Note
    Metadata links take priority over naming convention.
    For details on both options continue reading.

### Metadata links

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

### Naming convention

When metadata links are not set, PSRule for Azure will use a naming convention to link to template files.
PSRule for Azure uses the parameter file prefix `<templateName>.parameters.json` to link to a template.
When linking using naming convention, the template and the parameter file must be in the same sub-directory.

!!! Example
    A parameter file named `azuredeploy.parameters.json` links to the template file named `azuredeploy.json`.

*[CI]: continuous integration
*[PR]: Pull Request

  [1]: creating-your-pipeline.md#expandtemplateparameterfiles
