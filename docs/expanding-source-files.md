---
author: BernieWhite
---

# Expanding source files

PSRule for Azure supports analyzing resources contained within Azure Infrastructure as Code.

!!! Abstract
    This topic covers what source expansion is, why it's important, and how to use it within PSRule for Azure.

## Source expansion

PSRule for Azure goes beyond linting Azure Bicep and template files for syntax.
Source expansion performs context specific static analysis on Azure resources.
Azure resources are analyzed before deployment as if they are deployed.

This provides some unique benefits such as:

- **Improve success** &mdash; Azure resources are resolved before deployment,
  increasing success by finding errors earlier such as within a PR.
  - Detect common templates issues such as missing parameters and JSON structure.
  - Identify deployment issues such as invalid resource names and incorrect resource identifiers.
- **As deployed** &mdash; Analysis of Azure resources against Azure WAF as if they are deployed.
  - Parameters, conditional resources, functions (built-in and user defined), variables,
    and copy loops are resolved.
  - Azure resource names are shown in passing and failing results.
    Resolving issues with resource configurations can be targeted by resource.
  - Resource file locations for template and parameter files are included in results.
- **Suppression by resource name** &mdash; Azure resource names can be used to apply exceptions.
  - Suppression allows for individual resources to be excluded from rules by name.
- **Offline support** &mdash; Static analysis is performed against source files instead of deployed resources.
  - Some functions that may be included in templates dynamically query Azure for current state.
    For these functions standard placeholder values are used by default.
    Functions that use placeholders include `reference`, `list*`.

### Feature support

Source expansion is supported with:

- **Azure template and parameter files** &mdash; Azure templates are expanded from parameter files.
  Link parameter files to templates by metadata or naming convention.
  See [Using templates][1] for a detailed explanation of how to do this.
- **Azure Bicep deployments** &mdash; Files with the `.bicep` extension are detected and expanded.
  See [Using Bicep source][2] for a detailed explanation of how to do this.
- **Azure Bicep modules with tests** &mdash; Reusable Bicep modules can be expanded with tests.
  See [Using Bicep source][2] for a detailed explanation of how to do this.

  [1]: using-templates.md
  [2]: using-bicep.md

### Limitations

Currently the following limitations apply:

- Required parameters in must be provided in parameter files or Bicep deployments.
- Nested templates are expanded, external templates are not.
  - Deployment resources that link to an external template are returned as a resource.
- Sub-resources such as diagnostic logs or configurations are automatically nested.
Automatic nesting a sub-resource requires:
  - The parent resource is defined in the same template.
  - The sub-resource depends on the parent resource.
- The `environment()` template function always returns values for Azure public cloud.
- References to Key Vault secrets are not expanded.
  A placeholder value is used instead.
- The `reference()` function will return objects for resources within the same template.
  For resources that are not in the same template, a placeholder value is used instead.
- Multi-line strings are not supported.
- Template expressions up to a maximum of 100,000 characters are supported.

In addition, currently the following limitation apply to using Bicep source files:

- The Bicep CLI must be installed.
  When using GitHub Actions or Azure Pipelines the Bicep CLI is pre-installed.
- Location of issues in Bicep source files is not supported.
- Expansion of Bicep source files times out after 5 seconds by default.
  The timeout can be overridden by setting the [AZURE_BICEP_FILE_EXPANSION_TIMEOUT][3] option.

  [3]: setup/setup-bicep.md#configuring-timeout

## Strong type

String parameters are commonly used to pass values such as a resource Id or location.
PSRule for Azure provides additional support to allow parameters to be strongly typed.
When a parameter is strongly typed, the value is checked against the type during expansion.

To configure a strong type for a parameter set the `strongType` metadata property on the parameter.
The strong type will be set to the resource type that the parameter will accept, such as `Microsoft.OperationalInsights/workspaces`.

=== "Template"

    ```json
    {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "workspaceId": {
                "type": "string",
                "metadata": {
                    "description": "The resource identifier for a Log Analytics workspace.",
                    "strongType": "Microsoft.OperationalInsights/workspaces"
                }
            }
        }
    }
    ```

=== "Bicep"

    ```bicep
    @metadata({
      strongType: 'Microsoft.OperationalInsights/workspaces'
    })
    @description('The resource identifier for a Log Analytics workspace.')
    param workspaceId string
    ```

Strong type also supports the following non-resource type values:

- `location` - Specifies the parameter must contain any valid Azure location.

## Scope functions

Azure deployments support a number of [scope functions][4] can be used within Infrastructure as Code.
When using PSRule for Azure, these functions have a default meaning that can be configured.

When configuring scope functions, only the properties you want to override has to be specified.
Unspecified properties will inherit from the defaults.

  [4]: https://learn.microsoft.com/azure/azure-resource-manager/templates/template-functions-scope

### Subscription

The `subscription()` function will return the following unless overridden:

```yaml
subscriptionId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
displayName: 'PSRule Test Subscription'
state: 'NotDefined'
```

To override, configure [`AZURE_SUBSCRIPTION`](setup/configuring-expansion.md#deployment-subscription).

### Resource Group

The `resourceGroup()` function will return the following unless overridden:

```yaml
name: 'ps-rule-test-rg'
location: 'eastus'
tags: { }
properties:
  provisioningState: 'Succeeded'
```

To override, configure [`AZURE_RESOURCE_GROUP`](setup/configuring-expansion.md#deployment-resource-group).

### Tenant

The `tenant()` function will return the following unless overridden:

```yaml
countryCode: 'US'
tenantId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
displayName: 'PSRule'
```

To override, configure [`AZURE_TENANT`](setup/configuring-expansion.md#deployment-tenant).

### Management Group

The `managementGroup()` function will return the following unless overridden:

```yaml
name: 'psrule-test'
properties:
  displyName: 'PSRule Test Management Group'
```

To override, configure [`AZURE_MANAGEMENT_GROUP`](setup/configuring-expansion.md#deployment-management-group).

*[WAF]: Well-Architected Framework
*[ARM]: Azure Resource Manager
*[PR]: Pull Request
*[JSON]: JavaScript Object Notation
