---
description: This topic covers how you can test Azure resources within Bicep source files with PSRule for Azure.
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
    To learn more about why this is important see [Expanding source files][8].

  [8]: expanding-source-files.md

## Enabling expansion

To expand Bicep deployments configure `ps-rule.yaml` with the `AZURE_BICEP_FILE_EXPANSION` option.

```yaml title="ps-rule.yaml"
# YAML: Enable expansion for Bicep source files.
configuration:
  AZURE_BICEP_FILE_EXPANSION: true
```

!!! Note
    If you are using JSON parameter files exclusively, you do not need to set this option.
    Instead continue reading [using parameter files](#usingparameterfiles).

### Setup Bicep

To expand Azure resources for analysis from Bicep source files the Bicep CLI is required.
The Bicep CLI is already installed on hosted runners and agents used by GitHub Actions and Azure Pipelines.
For details on how to configure Bicep for PSRule for Azure see [Setup Bicep][1].

  [1]: setup/setup-bicep.md

### Building files

It's not necessary to build `.bicep` files with `bicep build` or `az bicep build`.
PSRule will automatically detect and build `.bicep` files.
You may choose to pre-build `.bicep` files if the Bicep CLI is not available when PSRule is run.

!!! Important
    If using this method, follow [using templates](using-templates.md) instead.
    Using `bicep build` transpiles Bicep code into an Azure template `.json`.

## Testing Bicep modules

Bicep allows you to separate out complex details into separate files called [modules][2].
To expand resources, any parameters must be resolved.

!!! Tip
    If you are not familiar with the concept of expansion within PSRule for Azure see [Expanding source files][8].

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

  [2]: https://learn.microsoft.com/azure/azure-resource-manager/bicep/modules

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

## Using parameter files

When using Bicep, you don't need to use parameter files.
You can call `.bicep` files directly from other `.bicep` files with modules by using the `module` keyword.

Alternatively, Bicep supports two options for parameter files:

- **JSON parameter files** &mdash; This format uses conventional JSON syntax compatible with ARM templates.
- **Bicep parameter files** &mdash; This format uses Bicep language from a `.bicepparam` file to reference a Bicep module.

Each option is described in more detail in the following sections.

### Using JSON parameter files

You can choose to expand and test a Bicep module from JSON parameter files [by metadata][7].

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

  [7]: using-templates.md#by-metadata

### Using Bicep parameter files

:octicons-beaker-24:{ .experimental } Experimental · :octicons-milestone-24: v1.27.0

You can use `.bicepparam` files to reference your Bicep modules as a method for providing parameters.
Using the Bicep parameter file format, allows you to get many of the benefits of the Bicep language.

For example:

```bicepparam
using 'template.bicep'

param storageAccountName = 'bicepstorage001'
param tags = {
  env: 'test'
}
```

Presently, to use this feature you must:

1. Enable the experimental feature in `bicepconfig.json`.
2. Enable expansion of Bicep parameter files in `ps-rule.yaml`.

For example:

```json title="bicepconfig.json"
{
  "experimentalFeaturesEnabled": {
    "paramsFiles": true
  }
}
```

```yaml title="ps-rule.yaml"
configuration:
  AZURE_BICEP_PARAMS_FILE_EXPANSION: true
```

!!! Experimental "Experimental - [Learn more][13]"
    Bicep parameter files are a work in progress.
    This feature will be transitioned to stable after the Bicep CLI support is finalized.

!!! Learn
    To learn more about Bicep parameter files see [Create parameters files for Bicep deployment][16].

  [13]: versioning.md#experimental-features
  [16]: https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameter-files?tabs=Bicep

## Restoring modules from a private registry

Bicep modules can be stored in a private registry.
Storing modules in a private registry gives you a central location to reference modules across your organization.

To test Bicep deployments which uses modules stored in a private registry, these modules must be restored.
The restore process automatically occurs when PSRule is run, however some additional steps are required to authenticate.

To prepare your registry for storing Bicep modules see [Create private registry for Bicep modules][15].

To configure authentication for PSRule to a private registry:

- [Configure `bicepconfig.json`](#configure-bicepconfigjson)
- [Granting access to a private registry](#granting-access-to-a-private-registry)
- [Set pipeline environment variables](#set-pipeline-environment-variables)

Some organizations may want to expose Bicep modules publicly.
This can be configured by enabling anonymous pull access.
To configure your registry see [Make your container registry content publicly available][14].

!!! Note
    To use anonymous pull access to a registry you must use a minimum of Bicep CLI version **0.15.31**.
    You can configure PSRule to check for the minimum Bicep version.
    See [configuring minimum version][10] for information on how to enable this check.

  [15]: https://learn.microsoft.com/azure/azure-resource-manager/bicep/private-module-registry
  [14]: https://learn.microsoft.com/azure/container-registry/anonymous-pull-access
  [10]: setup/setup-bicep.md#configuring-minimum-version

### Configure `bicepconfig.json`

To authenticate to a private registry, configure `bicepconfig.json` by setting [credentialPrecedence][3].
This setting determines the order to find a credential to use when authenticating to the registry.

Use the following credential type based on your environment as the first value of the [credentialPrecedence][3] setting:

- `Environment` &mdash; Use environment variables to authenticate to the registry.
  This is the most common scenario for CI pipelines and works for cloud-hosted or self-hosted agents/ private runners.
- `ManagedIdentity` &mdash; Use a managed identity to authenticate to the registry.
  This may be applicable for scenarios where you are using self-hosted agents or private runners.
  You must [configure a System-Assigned managed identity][9] for the Azure Virtual Machine or Virtual Machine Scale Set.

!!! Example "Example `bicepconfig.json`"

    ```json
    {
      "credentialPrecedence": [
        "Environment",
        "AzureCLI",
      ]
    }
    ```

!!! Tip
    The `bicepconfig.json` configures the Bicep CLI.
    You should commit this file into a repository along with your Bicep code.

  [9]: https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview

### Granting access to a private registry

To access a private registry use an Azure AD identity which has been granted permissions to pull Bicep modules.
When using `Environment` credential type, see [create a service principal that can access resources][11] to create the identity.
If you are using the `ManagedIdentity` credential type, an identity is created for when you [configure the managed identity][9].

After configuring the identity, [grant access using the `AcrPull`][12] built-in RBAC role on the Azure Container Registry.

  [12]: https://learn.microsoft.com/azure/container-registry/container-registry-faq#how-do-i-grant-access-to-pull-or-push-images-without-permission-to-manage-the-registry-resource-

### Set pipeline environment variables

When using the `Environment` credential type, environment variables should be set in the pipeline.
Typically, the following three environment variables should be set:

- `AZURE_CLIENT_ID` &mdash; The Client ID (also called Application ID) of an App Registration in Azure AD.
  This will be represented as a GUID.
- `AZURE_CLIENT_SECRET` &mdash; A valid secret that was generated for the App Registration.
- `AZURE_TENANT_ID` &mdash; The Tenant ID that identifies your specific Azure AD tenant where your App Registration is created.
  This will be represented as a GUID.

!!! Note
    The environment credential type also supports other environment variables that may be applicable to your environment.
    To see a list visit [EnvironmentCredential Class][4].

=== "GitHub Actions"

    Configure the `microsoft/ps-rule` action with Azure environment variables.

    ```yaml
    - name: Analyze Azure template files
      uses: microsoft/ps-rule@v2.9.0
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

  [3]: https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-config-modules#configure-profiles-and-credentials
  [4]: https://learn.microsoft.com/dotnet/api/azure.identity.environmentcredential
  [5]: https://docs.github.com/actions/security-guides/using-secrets-in-github-actions
  [6]: https://learn.microsoft.com/azure/devops/pipelines/library/variable-groups
  [11]: https://learn.microsoft.com/entra/identity-platform/howto-create-service-principal-portal

## Recommended content

- [Setup Bicep](setup/setup-bicep.md)
- [Bicep compilation timeout](setup/configuring-expansion.md#bicep-compilation-timeout)
- [Troubleshooting](troubleshooting.md)

*[WAF]: Well-Architected Framework
*[ARM]: Azure Resource Manager
