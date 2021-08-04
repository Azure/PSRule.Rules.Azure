---
author: BernieWhite
---

# Setup Bicep

To expand Azure resources for analysis from Bicep source files the Bicep CLI is required.
The Bicep CLI is already installed on hosted runners and agents used by GitHub Action and Azure Pipelines.

!!! Abstract
    This topic covers setting up support for analyzing Azure resources within Bicep source file.

## Installing Bicep CLI

PSRule for Azure requires a minimum of Bicep CLI version **0.4.451**.

You may need to install or upgrade the Bicep CLI in the following scenarios:

- Your Bicep source files require a newer version of the CLI then supported by hosted agents.
  The Bicep CLI version can be found in the [included software][1] list for each supported platform.
- You are using self-hosted runners with your GitHub Actions workflow.
- You are using self-hosted agents with Azure Pipelines.
- You are performing local validation or using a different CI platform.

The Bicep CLI can be installed on MacOS, Linux, and Windows.
For installation instructions see [Setup your Bicep development environment][2].

  [1]: https://github.com/actions/virtual-environments
  [2]: https://github.com/Azure/bicep/blob/main/docs/installing.md

!!! Tip
    When installing Bicep using the Azure CLI, Bicep is not added to the `PATH` environment variable.
    To use PSRule for Azure with the Azure CLI set the `PSRULE_AZURE_BICEP_USE_AZURE_CLI` to `true`.
    Setting this environment variable is explained in the next section.

## Setting environment variables

When expanding Bicep files, the path to the Bicep binary is required.
By default, the `PATH` environment variable will be used to discover the binary path.
When using this option, add the sub-directory containing the Bicep binary to the environment variable.

Alternatively, the path can be overridden by setting the `PSRULE_AZURE_BICEP_PATH` environment variable.
When setting `PSRULE_AZURE_BICEP_PATH` specify the full path to the Bicep binary including the file name.
File names used for Bicep binaries include `bicep`, or `bicep.exe`.

For example:

```bash
# Bash: Setting environment variable
export PSRULE_AZURE_BICEP_PATH='/usr/local/bin/bicep'
```

```powershell
# PowerShell: Setting environment variable
$Env:PSRULE_AZURE_BICEP_PATH = '/usr/local/bin/bicep';
```

```yaml
# GitHub Actions: Setting environment variable
env:
  PSRULE_AZURE_BICEP_PATH: '/usr/local/bin/bicep'
```

```yaml
# Azure Pipelines: Setting environment variable
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

For example:

```bash
# Bash: Setting environment variable
export PSRULE_AZURE_BICEP_USE_AZURE_CLI=true
```

```powershell
# PowerShell: Setting environment variable
$Env:PSRULE_AZURE_BICEP_USE_AZURE_CLI = 'true'
```

```yaml
# GitHub Actions: Setting environment variable
env:
  PSRULE_AZURE_BICEP_USE_AZURE_CLI: true
```

```yaml
# Azure Pipelines: Setting environment variable
variables:
- name: PSRULE_AZURE_BICEP_USE_AZURE_CLI
  value: true
```

  [3]: https://github.com/Azure/bicep/blob/main/docs/installing.md#install-and-manage-via-azure-cli-easiest

### Additional arguments

For configuration, additional arguments can be passed to the Bicep CLI.
This is intended to improve forward compatibility with Bicep CLI.

To configure additional arguments, set the `PSRULE_AZURE_BICEP_ARGS` environment variable.

## Configuring expansion

[:octicons-book-24: Docs][4] · :octicons-beaker-24: Experimental

PSRule for Azure can automatically expand Bicep source files.
When enabled, PSRule for Azure automatically expands and analyzes Azure resource from `.bicep` files.

To enabled this feature, set the `Configuration.AZURE_BICEP_FILE_EXPANSION` to `true`.
This option can be set within the `ps-rule.yaml` file.

```yaml
configuration:
  # Enable automatic expansion of bicep source files
  AZURE_BICEP_FILE_EXPANSION: true
```

  [4]: configuring-expansion.md#bicepsourceexpansion
