---
author: BernieWhite
---

# Configuring options

PSRule for Azure comes with many configuration options.
Additionally, the PSRule engine includes several options that apply to all rules.
You can visit the [about_PSRule_Options][1] topic to read about general PSRule options.

  [1]: https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Options/

## Setting options

Configuration options are set within the `ps-rule.yaml` file.
PSRule will automatically find this file within the current working directory.
To set options, create a new file named `ps-rule.yaml` in the root directory of your repository.

For configuring pre-flight analysis, create a `ps-rule.yaml` in your current working directory.

!!! Tip
    This file should be committed to your repository so it is available when your pipeline runs.

!!! Note
    Use all lowercase characters `ps-rule.yaml` to name the file.
    On case-sensitive file systems, a file with uppercase characters may not be found.

Configuration can be combined as indented keys.
Use comments to add context.

!!! Example "Example `ps-rule.yaml`"

    ```yaml
    requires:
      # Require a minimum of PSRule for Azure v1.30.0
      PSRule.Rules.Azure: '>=1.30.0'

    configuration:
      # Enable expansion of Azure Template files.
      AZURE_PARAMETER_FILE_EXPANSION: true

      # Enable expansion of Azure Bicep files.
      AZURE_BICEP_FILE_EXPANSION: true

      # Configure the timeout for bicep build to 15 seconds.
      AZURE_BICEP_FILE_EXPANSION_TIMEOUT: 15

      # Enable Bicep CLI checks.
      AZURE_BICEP_CHECK_TOOL: true

      # Optionally, configure the minimum version of the Bicep CLI.
      AZURE_BICEP_MINIMUM_VERSION: '0.16.2'

      # Configure the minimum AKS cluster version.
      AZURE_AKS_CLUSTER_MINIMUM_VERSION: '1.27.7'

    rule:
      # Enable custom rules that don't exist in the baseline
      includeLocal: true
      exclude:
      # Ignore the following rules for all resources
      - Azure.VM.UseHybridUseBenefit
      - Azure.VM.Standalone

    suppression:
      Azure.AKS.AuthorizedIPs:
      # Exclude the following externally managed AKS clusters
      - aks-cluster-prod-eus-001
      Azure.Storage.SoftDelete:
      # Exclude the following non-production storage accounts
      - storagedeveus6jo36t
      - storagedeveus1df278
    ```

!!! Tip
    YAML can be a bit particular about indenting.
    If something is not working, double check that you have consistent spacing in your options file.
    We recommend using two (2) spaces to indent.

## Setting environment variables

In addition to `ps-rule.yaml`, most options can be set using environment variables.
When configuring environment variables we recommend that all capital letters are used.
This is because environment variables are case-sensitive on some operating systems.

PSRule environment variables use a consistent naming pattern of `PSRULE_<PARENT>_<NAME>`.
Where `<PARENT>` is the parent class and `<NAME>` is the specific option.

When setting environment variables:

- Enum values are set by string and are not case-sensitive.
  For example `PSRULE_OUTPUT_FORMAT` could be set to `Yaml`.
- Boolean values are set by `true`, `false`, `1`, or `0` and are not case-sensitive.
  For example `PSRULE_CONFIGURATION_AZURE_BICEP_FILE_EXPANSION` could be set to `true`.
- String array values can specify multiple items by using a semi-colon separator.
  For example `PSRULE_RULE_EXCLUDE` could be set to `'Azure.VM.UseHybridUseBenefit;Azure.VM.Standalone'`.

=== "GitHub Actions"

    ```yaml
    env:
      PSRULE_CONFIGURATION_AZURE_BICEP_FILE_EXPANSION: true
      PSRULE_OUTPUT_FORMAT: Yaml
      PSRULE_RULE_EXCLUDE: 'Azure.VM.UseHybridUseBenefit;Azure.VM.Standalone'
    ```

=== "Azure Pipelines"

    ```yaml
    variables:
    - name: PSRULE_CONFIGURATION_AZURE_BICEP_FILE_EXPANSION
      value: true
    - name: PSRULE_OUTPUT_FORMAT
      value: Yaml
    - name: PSRULE_RULE_EXCLUDE
      value: 'Azure.VM.UseHybridUseBenefit;Azure.VM.Standalone'
    ```

=== "PowerShell"

    ```powershell
    $Env:PSRULE_CONFIGURATION_AZURE_BICEP_FILE_EXPANSION = 'true'
    $Env:PSRULE_OUTPUT_FORMAT = 'Yaml'
    $Env:PSRULE_RULE_EXCLUDE = 'Azure.VM.UseHybridUseBenefit;Azure.VM.Standalone'
    ```

=== "Bash"

    ```bash
    export PSRULE_CONFIGURATION_AZURE_BICEP_FILE_EXPANSION=true
    export PSRULE_OUTPUT_FORMAT=Yaml
    export PSRULE_RULE_EXCLUDE='Azure.VM.UseHybridUseBenefit;Azure.VM.Standalone'
    ```
