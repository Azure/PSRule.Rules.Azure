---
author: BernieWhite
---

# Setup Bicep

To expand Azure resources for analysis from Bicep source files the Bicep CLI is required.
The Bicep CLI is already installed on hosted runners and agents used by GitHub Action and Azure Pipelines.

!!! Abstract
    This topic covers setting up support for analyzing Azure resources within Bicep source file.

## Installing Bicep CLI

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
    For PSRule for Azure to find the Bicep CLI binary set the `PSRULE_AZURE_BICEP_PATH` environment variable.
    Setting this environment variable is explained in the next section.

## Setting environment variables

When expanding Bicep files, the path to the Bicep binary is required.
By default, the `PATH` environment variable will be used to discover the binary path.
When using this option, add the sub-directory containing the Bicep binary to the environment variable.

Alternatively, the path can be overridden by setting the `PSRULE_AZURE_BICEP_PATH` environment variable.
When setting `PSRULE_AZURE_BICEP_PATH` specify the full path to the Bicep binary including the file name.
File names used for Bicep binaries include `bicep`, `bicep.bin`, and `bicep.exe`.

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

## Configuring expansion

[:octicons-book-24: Docs][3] · :octicons-beaker-24: Experimental

PSRule for Azure can automatically expand Bicep source files.
When enabled, PSRule for Azure automatically expands and analyzes Azure resource from `.bicep` files.

To enabled this feature, set the `Configuration.AZURE_BICEP_FILE_EXPANSION` to `true`.
This option can be set within the `ps-rule.yaml` file.

```yaml
configuration:
  # Enable automatic expansion of bicep source files
  AZURE_BICEP_FILE_EXPANSION: true
```

  [3]: configuring-expansion.md#bicepsourceexpansion
