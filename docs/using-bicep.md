---
author: BernieWhite
---

# Using Bicep source

PSRule for Azure discovers and analyzes Azure resources contained within Bicep files.
To enable this feature, you need to:

- Enable expansion.
- For modules (if used):
  - Define a deployment or parameters file.
  - Configure path exclusions.

!!! Abstract
    This topic covers how you can validate Azure resources within `.bicep` files.
    To learn more about why this is important see [Expanding source files](expanding-source-files.md).

## Enabling expansion

To expand Bicep deployments configure `ps-rule.yaml` with the `AZURE_BICEP_FILE_EXPANSION` option.

```yaml title="ps-rule.yaml"
# YAML: Enable expansion for Bicep source files.
configuration:
  AZURE_BICEP_FILE_EXPANSION: true
```

!!! Note
    If you are using JSON parameter files exclusively, you do not need to set this option.
    Instead continue reading [Using parameter files](#usingparameterfiles).

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
      # Exclude bicepconfig.json
      - 'bicepconfig.json'
      # Exclude module files
      - 'modules/**/*.bicep'
      # Include test files from modules
      - '!modules/**/*.tests.bicep'
    ```

!!! Note
    In this example, Bicep files such as `deploy.bicep` in other directories will be expanded.

### Restoring modules from a private registry

Bicep modules can be stored in a private registry.
Storing modules in a private registry gives you a central location to reference modules across your organization.

To test Bicep deployments which uses modules stored in a private registry, these modules must be restored.
The restore process automatically occurs when PSRule is run, however must be authenticated.

To authenticate to a private registry configure `bicepconfig.json` by setting [credentialPrecedence][3].
This setting determines the order to find a credential to use when authenticating to the registry.

You may need to [configure credentials][4] to access the private registry from a CI pipeline.

=== "GitHub Actions"

    Configure the `microsoft/ps-rule` action with Azure environment variables.

    ```yaml
    - name: Analyze Azure template files
      uses: microsoft/ps-rule@v2.2.0
      with:
        modules: PSRule.Rules.Azure,PSRule.Monitor
        conventions: Monitor.LogAnalytics.Import
      env:
        # Define environment variables using GitHub encrypted secrets
        AZURE_CLIENT_ID: ${{ secrets.BICEP_REGISTRY_CLIENTID }}
        AZURE_CLIENT_SECRET: ${{ secrets.BICEP_REGISTRY_CLIENTSECRET }}
        AZURE_TENANT_ID: ${{ secrets.BICEP_REGISTRY_TENANTID }}
    ```

    !!! Important
        Environment variables can be configured in the workflow or from a secret.
        To keep `BICEP_REGISTRY_CLIENTSECRET` secure, use an [encrypted secret][5].

=== "Azure Pipelines"

    Configure the `ps-rule-assert` task with Azure environment variables.

    ```yaml
    - task: ps-rule-assert@2
      displayName: Analyze Azure template files
      inputs:
        modules: 'PSRule.Rules.Azure'
      env:
        # Define environment variables within Azure Pipelines
        AZURE_CLIENT_ID: $(BICEPREGISTRYCLIENTID)
        AZURE_CLIENT_SECRET: $(BICEPREGISTRYCLIENTSECRET)
        AZURE_TENANT_ID: $(BICEPREGISTRYTENANTID)
    ```

  !!! Important
      Variables can be configured in YAML, on the pipeline, or referenced from a defined variable group.
      To keep `BICEPREGISTRYCLIENTSECRET` secure, use a [variable group][6] linked to an Azure Key Vault.

  [3]: https://docs.microsoft.com/azure/azure-resource-manager/bicep/bicep-config#credential-precedence
  [4]: https://docs.microsoft.com/dotnet/api/azure.identity.environmentcredential
  [5]: https://docs.github.com/actions/reference/encrypted-secrets
  [6]: https://docs.microsoft.com/azure/devops/pipelines/library/variable-groups

### Using parameter files

When using Bicep, you don't need to use parameter files.
You can call `.bicep` files directly from other `.bicep` files with modules by using the `module` keyword.
Alternatively, you can choose to expand and test a Bicep module from JSON parameter files [by metadata][7].

When using parameter files exclusively,
the `AZURE_BICEP_FILE_EXPANSION` configuration option does not need to be set.
Instead set the `AZURE_PARAMETER_FILE_EXPANSION` configuration option to `true`.
This option will discover Bicep files from parameter metadata.

!!! Example "Example `ps-rule.yaml`"

    ```yaml
    configuration:
      # Enable expansion for Bicep module from parameter files.
      AZURE_PARAMETER_FILE_EXPANSION: true

    input:
      pathIgnore:
      # Exclude bicepconfig.json
      - 'bicepconfig.json'
      # Exclude module files
      - 'modules/**/*.bicep'
    ```

!!! Example "Example `template.parameters.json`"

    ```json
    {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
        "contentVersion": "1.0.0.0",
        "metadata": {
            "template": "./template.bicep"
        },
        "parameters": {
            "storageAccountName": {
                "value": "bicepstorage001"
            },
            "tags": {
                "value": {
                    "env": "test"
                }
            }
        }
    }
    ```

  [7]: using-templates.md#bymetadata

*[WAF]: Well-Architected Framework
*[ARM]: Azure Resource Manager
