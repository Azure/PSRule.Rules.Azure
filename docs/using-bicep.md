---
author: BernieWhite
---

# Using Bicep source

PSRule for Azure discovers and analyzes Azure resources contained within Bicep files.
To enable this feature, you need to:

- Enable expansion.
- For modules (if used):
  - Define a deployment.
  - Configure path exclusions.

!!! Abstract
    This topic covers how you can validate Azure resources within `.bicep` files.
    To learn more about why this is important see [Expanding source files](expanding-source-files.md).

## Enabling expansion

To expand Bicep deployments configure `ps-rule.yaml` with the `AZURE_BICEP_FILE_EXPANSION` option.

```yaml
# YAML: Enable expansion for Bicep source files.
configuration:
  AZURE_BICEP_FILE_EXPANSION: true
```

### Setup Bicep

To expand Azure resources for analysis from Bicep source files the Bicep CLI is required.
The Bicep CLI is already installed on hosted runners and agents used by GitHub Actions and Azure Pipelines.
For details on how to configure Bicep for PSRule for Azure see [Setup Bicep][1].

  [1]: setup/setup-bicep.md

### Building files

It's not nessecary to build `.bicep` files with `bicep build` or `az bicep build`.
PSRule will automatically detect and build `.bicep` files.
You may choose to pre-build `.bicep` files if the Bicep CLI is not available when PSRule is run.

!!! Important
    If using this method, follow [Using templates](using-templates.md) instead.
    Using `bicep build` transpiles Bicep code into an Azure template `.json`.

## Testing Bicep modules

Bicep allows you to separate out complex details into separate files called [modules][2].
To expand resources, any parameters must be resolved.

Two types of parameters exist, _required_ (also called mandatory) and _optional_.
An optional parameter is any parameter with a default value.
Required parameters do not have a default value and must be specified.

!!! Example "Example `modules/storage/main.bicep`"

    ```bicep
    // Required parameter
    param name string

    // Optional parameters
    param location string = resourceGroup().location
    param sku string = 'Standard_LRS'
    ```

To specify required parameters for a module, create a deployment or test that references the module.

!!! Example "Example `deploy.bicep`"

    ```bicep
    // Deploy storage account to production subscription
    module storageAccount './modules/storage/main.bicep' = {
      name: 'deploy-storage'
      params: {
        name: 'stpsrulebicep001'
        sku: 'Standard_GRS'
      }
    }
    ```

!!! Example "Example `modules/storage/.tests/main.tests.bicep`"

    ```bicep
    // Test with only required parameters
    module test_required_params '../main.bicep' = {
      name: 'test_required_params'
      params: {
        name: 'sttest001'
      }
    }
    ```

  [2]: https://docs.microsoft.com/azure/azure-resource-manager/bicep/modules

### Configuring path exclusions

Unless configured, PSRule will discover all `.bicep` files when expansion is enabled.
Bicep module files with required parameters will not be able be expanded and should be excluded.
Instead expand resources from deployments or tests.

To do this configure `ps-rule.yaml` with the `input.pathIgnore` option.

!!! Example "Example `ps-rule.yaml`"

    ```yaml
    configuration:
      # Enable expansion for Bicep source files.
      AZURE_BICEP_FILE_EXPANSION: true

    input:
      pathIgnore:
      # Exclude module files
      - 'modules/**/*.bicep'
      # Include test files from modules
      - '!modules/**/*.tests.bicep'
    ```

!!! Note
    In this example, Bicep files such as `deploy.bicep` in other directories will be expanded.

*[WAF]: Well-Architected Framework
*[ARM]: Azure Resource Manager

[feedback]: https://github.com/Azure/PSRule.Rules.Azure/discussions
[issues]: https://github.com/Azure/PSRule.Rules.Azure/issues
