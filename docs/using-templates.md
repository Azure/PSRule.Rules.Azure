---
author: BernieWhite
---

# Using templates

PSRule for Azure detects Azure template and parameter files in your repository based on their schemas.
This provides template and parameter file linting for structure and general usage.

!!! Abstract
    This topic covers how to use Azure templates and metadata to improve the success of Azure deployments.

## Parameter file expansion

In additional to template and parameter file linting,
PSRule for Azure can automatically resolve template and parameter file context at runtime.
Resolved context provides some unique benefits such as:

- **Improve success** &mdash; Templates are resolved before deployment.
  - Detect issues with invalid resource names, missing parameters, and JSON structure.
  - Increases success of deployments by finding errors earlier such as within a PR.
- **As deployed** &mdash; Analysis of Azure resources against Azure WAF as if they are deployed.
  - Parameters, conditional resources, functions (built-in and user defined), variables,
    and copy loops are resolved.
  - Azure resource names are shown in passing and failing results.
    Resolving issues with resource configurations can be targeted by resource.
  - Resource file locations for template and parameter files are included in results.
- **Suppression by resource name** &mdash; Azure resource names can be used to apply exceptions.
  - Suppression allows for individual resources to be excluded from rules by name.

To get these benefits, Azure parameter files must be associated to templates.
PSRule for Azure uses links to achieve this.

!!! Note
    Azure parameter file expansion needs to be enabled.
    It is not enabled by default to preserve the default behavior prior to PSRule for Azure v1.4.0.
    [Creating your pipeline][1] covers how to enable this in a CI pipeline.

  [1]: creating-your-pipeline.md#expandtemplateparameterfiles

### Feature support

Expansion of Azure template parameter files works with Azure Resource Manager (ARM) features.
By default this is an offline process, requiring no connectivity to Azure.
Some functions that may be included in templates dynamically query Azure for current state.
For these functions standard placeholder values are used by default.
Functions that use placeholders include `reference`, `list*`.

The `subscription()` function will return the following unless overridden with `AZURE_SUBSCRIPTION`:

```yaml
subscriptionId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
displayName: 'PSRule Test Subscription'
state: 'NotDefined'
```

The `resourceGroup()` function will return the following unless overridden with `AZURE_RESOURCE_GROUP`:

```yaml
name: 'ps-rule-test-rg'
location: 'eastus'
tags: { }
properties:
  provisioningState: 'Succeeded'
```

The `tenant()` function will return the following unless overridden with `AZURE_TENANT`:

```yaml
countryCode: 'US'
tenantId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
displayName: 'PSRule'
```

The `managementGroup()` function will return the following unless overridden with `AZURE_MANAGEMENT_GROUP`:

```yaml
name: 'psrule-test'
properties:
  displyName: 'PSRule Test Management Group'
```

To override, see [Configuring expansion](setup/configuring-expansion.md).

Currently the following limitations apply:

- Nested templates are expanded, external templates are not.
  - Deployment resources that link to an external template are returned as a resource.
- Sub-resources such as diagnostic logs or configurations are automatically nested.
Automatic nesting a sub-resource requires:
  - The parent resource is defined in the same template.
  - The sub-resource depends on the parent resource.
- The `environment` template function always returns values for Azure public cloud.
- References to Key Vault secrets are not expanded.
  A placeholder value is used instead.
- Multi-line strings are not supported.
- Template expressions up to a maximum of 100,000 characters are supported.

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

!!! Tip
    By default, metadata links are not required.
    By configuring the `AZURE_PARAMETER_FILE_METADATA_LINK` option to `true`, this can be enforced.
    When configured, PSRule for Azure will fail parameter files that do not contain a metadata link.
    For details on `AZURE_PARAMETER_FILE_METADATA_LINK` see [Configuring expansion][2].

  [2]: setup/configuring-expansion.md#requiretemplatemetadatalink

### Naming convention

When metadata links are not set, PSRule for Azure will use a naming convention to link to template files.
PSRule for Azure uses the parameter file prefix `<templateName>.parameters.json` to link to a template.
When linking using naming convention, the template and the parameter file must be in the same sub-directory.

!!! Example
    A parameter file named `azuredeploy.parameters.json` links to the template file named `azuredeploy.json`.

## Strong type

String parameters are commonly used to pass values such as a resource Id or location.
PSRule for Azure provides additional support to allow parameters to be strongly typed.
When a parameter is strongly typed, the value is checked against the type during expansion.

To configure a strong type for a parameter set the `strongType` metadata property within the template.
The strong type will be set to the resource type that the parameter will accept, such as `Microsoft.OperationalInsights/workspaces`.

=== "Azure template"

    ```json
    {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "workspaceId": {
                "type": "string",
                "metadata": {
                    "description": "The resource identifer for a Log Analytics workspace.",
                    "strongType": "Microsoft.OperationalInsights/workspaces"
                }
            }
        }
    }
    ```

=== "Azure Bicep"

    ```bicep
    @metadata({
      description: 'The resource identifer for a Log Analytics workspace.'
      strongType: 'Microsoft.OperationalInsights/workspaces'
    })
    param workspaceId string
    ```

Strong type also supports the following non-resource type values:

- `location` - Specifies the parameter must contain any valid Azure location.

*[WAF]: Well-Architected Framework
*[ARM]: Azure Resource Manager
*[CI]: continuous integration
*[PR]: Pull Request
