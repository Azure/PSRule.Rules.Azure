---
title: Setup Azure Bicep
description: This topic covers setting up support for analyzing Azure resources within Bicep source files using PSRule for Azure.
author: BernieWhite
---

# Setup Bicep

To expand Azure resources for analysis from Bicep source files the Bicep CLI is required.
The Bicep CLI is already installed on hosted runners and agents used by GitHub Actions and Azure Pipelines.

!!! Abstract
    This topic covers setting up support for analyzing Azure resources within Bicep source files.

## Installing Bicep CLI

PSRule for Azure requires a minimum of Bicep CLI version **0.4.451**.
However the features you use within Bicep may require a newer version of the Bicep CLI.

You may need to install or upgrade the Bicep CLI in the following scenarios:

- Your Bicep source files require a newer version of the CLI then supported by hosted agents.
  The Bicep CLI version can be found in the [included software][1] list for each supported platform.
- You are using self-hosted runners with your GitHub Actions workflow.
- You are using self-hosted agents with Azure Pipelines.
- You are performing local validation or using a different CI platform.

The Bicep CLI can be installed on MacOS, Linux, and Windows.
For installation instructions see [Setup your Bicep development environment][2].

  [1]: https://github.com/actions/virtual-environments
  [2]: https://learn.microsoft.com/azure/azure-resource-manager/bicep/install

!!! Tip
    When installing Bicep using the Azure CLI, Bicep is not added to the `PATH` environment variable.
    To use PSRule for Azure with the Azure CLI set the `PSRULE_AZURE_BICEP_USE_AZURE_CLI` to `true`.
    Setting this environment variable is explained in the next section.

## Setting environment variables

When expanding Bicep files, the path to the Bicep CLI binary is required.
By default, the `PATH` environment variable will be used to discover the binary path.
When using this option, add the sub-directory containing the Bicep binary to the environment variable.

Alternatively, the path can be overridden by setting the `PSRULE_AZURE_BICEP_PATH` environment variable.
When setting `PSRULE_AZURE_BICEP_PATH` specify the full path to the Bicep binary including the file name.
File names used for Bicep binaries include `bicep`, or `bicep.exe`.

!!! Example

    ```bash title="Bash"
    export PSRULE_AZURE_BICEP_PATH='/usr/local/bin/bicep'
    ```

    ```powershell title="PowerShell"
    $Env:PSRULE_AZURE_BICEP_PATH = '/usr/local/bin/bicep';
    ```

    ```yaml title="GitHub Actions"
    env:
      PSRULE_AZURE_BICEP_PATH: '/usr/local/bin/bicep'
    ```

    ```yaml title="Azure Pipelines"
    variables:
    - name: PSRULE_AZURE_BICEP_PATH
      value: '/usr/local/bin/bicep'
    ```

### Using Azure CLI

By default, PSRule for Azure uses the Bicep CLI directly.
An additional option is to use the Azure CLI to invoke the Bicep CLI.
When using this option the required version of the CLI must be installed prior to using PSRule for Azure.
This is explained in [Setup your Bicep development environment][3].

To enable this option, set the `PSRULE_AZURE_BICEP_USE_AZURE_CLI` environment variable to `true`.

Syntax:

```bash title="Environment variable"
PSRULE_AZURE_BICEP_USE_AZURE_CLI: boolean
```

Default:

```bash title="Environment variable"
PSRULE_AZURE_BICEP_USE_AZURE_CLI: false
```

Example:

=== "GitHub Actions"

    ```yaml
    env:
      PSRULE_AZURE_BICEP_USE_AZURE_CLI: true
    ```

=== "Azure Pipelines"

    ```yaml
    variables:
    - name: PSRULE_AZURE_BICEP_USE_AZURE_CLI
      value: true
    ```

=== "PowerShell"

    ```powershell
    $Env:PSRULE_AZURE_BICEP_USE_AZURE_CLI = 'true'
    ```

=== "Bash"

    ```bash
    export PSRULE_AZURE_BICEP_USE_AZURE_CLI=true
    ```

  [3]: https://learn.microsoft.com/azure/azure-resource-manager/bicep/install#azure-cli

### Additional arguments

For configuration, additional arguments can be passed to the Bicep CLI.
This is intended to improve forward compatibility with Bicep CLI.

To configure additional arguments, set the `PSRULE_AZURE_BICEP_ARGS` environment variable.

## Configuring expansion

[:octicons-book-24: Docs][4]

PSRule for Azure can automatically expand Bicep source files.
When enabled, PSRule for Azure automatically expands and analyzes Azure resource from `.bicep` files.

To enabled this feature, set the `Configuration.AZURE_BICEP_FILE_EXPANSION` to `true`.
This option can be set within the `ps-rule.yaml` file.

```yaml title="ps-rule.yaml"
configuration:
  # Enable automatic expansion of bicep source files.
  AZURE_BICEP_FILE_EXPANSION: true
```

!!! Tip
    If you deploy Bicep code using JSON parameter files this option does not need to be set.
    Set `Configuration.AZURE_PARAMETER_FILE_EXPANSION` to `true` instead.
    See [Using parameter files][5] and [By metadata][6] for more information.

  [4]: ./configuring-expansion.md#bicep-source-expansion
  [5]: ../using-bicep.md#using-parameter-files
  [6]: ../using-templates.md#by-metadata

### Configuring timeout

[:octicons-book-24: Docs][7]

In certain environments it may be necessary to increase the default timeout for building Bicep files.
This can occur if your Bicep deployments are:

- Large and complex.
- Use nested modules.
- Use modules restored from a registry.

If you are experiencing timeout errors you can increase the default timeout of 5 seconds.
To configure the timeout, set `Configuration.AZURE_BICEP_FILE_EXPANSION_TIMEOUT` to the timeout in seconds.

```yaml title="ps-rule.yaml"
configuration:
  # Enable automatic expansion of bicep source files.
  AZURE_BICEP_FILE_EXPANSION: true

  # Configure the timeout for bicep build to 15 seconds.
  AZURE_BICEP_FILE_EXPANSION_TIMEOUT: 15
```

  [7]: ./configuring-expansion.md#bicep-compilation-timeout

### Checking Bicep version

<!-- module:version v1.25.0 -->

To use Bicep files with PSRule for Azure:

- The Bicep CLI must be installed or you must configure the Azure CLI.
- The version installed  must support the features you are using.

It may not always be clear which version of Bicep CLI is being used if you have multiple versions installed.
Additionally, the version installed in your CI/ CD pipeline may not be the same as your local development environment.

You can enable checking the Bicep CLI version during initialization.
To enable this feature, set the `Configuration.AZURE_BICEP_CHECK_TOOL` option to `true`.
Additionally, you can set the minimum version required using the `Configuration.AZURE_BICEP_MINIMUM_VERSION` option.

```yaml title="ps-rule.yaml"
configuration:
  # Enable Bicep CLI checks.
  AZURE_BICEP_CHECK_TOOL: true

  # Optionally, configure the minimum version of the Bicep CLI.
  AZURE_BICEP_MINIMUM_VERSION: '0.16.2'
```

### Configuring minimum version

<!-- module:version v1.25.0 -->

The Azure Bicep CLI is updated regularly, with new features and bug fixes.
You must use a version of the Bicep CLI that supports the features you are using.
If you attempt to use a feature that is not supported by the Bicep CLI, expansion will fail with a _BCP_ error.

!!! Tip
    It may not always be clear which version of Bicep CLI is being used if you have multiple versions installed.
    Using the Bicep CLI via `az bicep` is not the default, and you may need to [set additional options to use it](#using-azure-cli).

To ensure you are using the correct version of the Bicep CLI, you can configure the minimum version required.
If an earlier version is detected, PSRule for Azure will generate an error.
To configure the minimum version, set the `Configuration.AZURE_BICEP_MINIMUM_VERSION` option.
By default, the minimum version is set to `0.4.451`.

```yaml title="ps-rule.yaml"
configuration:
  # Enable Bicep CLI checks.
  AZURE_BICEP_CHECK_TOOL: true

  # Configure the minimum version of the Bicep CLI.
  AZURE_BICEP_MINIMUM_VERSION: '0.16.2'
```

!!! Important
    The `Configuration.AZURE_BICEP_CHECK_TOOL` **must** be set to `true` for this option to take effect.

!!! Tip
    For troubleshooting Bicep compilation errors see [Bicep compile errors][9].

  [9]: ../troubleshooting.md#bicep-compile-errors

## Recommended content

- [Using Bicep source](../using-bicep.md)
- [Restoring modules from a private registry](../using-bicep.md#restoring-modules-from-a-private-registry)
