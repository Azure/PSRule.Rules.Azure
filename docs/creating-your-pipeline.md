---
author: BernieWhite
---

# Creating your pipeline

You can use PSRule for Azure to validate Azure resources throughout their lifecycle.
By using validation within a continuous integration (CI) pipeline, any issues provide fast feedback.

Within the root directory of your infrastructure as code repository:

=== "GitHub Actions"

    Create a new GitHub Actions workflow by creating `.github/workflows/analyze-arm.yaml`.

    ```yaml
    name: Analyze templates
    on:
      push:
        branches:
        - main
      pull_request:
        branches:
        - main
    jobs:
      analyze_arm:
        name: Analyze templates
        runs-on: ubuntu-latest
        steps:
        - name: Checkout
          uses: actions/checkout@v3

        # Analyze Azure resources using PSRule for Azure
        - name: Analyze Azure template files
          uses: microsoft/ps-rule@v2.4.2
          with:
            modules: 'PSRule.Rules.Azure'
    ```

=== "Azure Pipelines"

    Create a new Azure DevOps YAML pipeline by creating `.azure-pipelines/analyze-arm.yaml`.

    ```yaml
    steps:

    # Analyze Azure resources using PSRule for Azure
    - task: ps-rule-assert@2
      displayName: Analyze Azure template files
      inputs:
        modules: 'PSRule.Rules.Azure'
    ```

This will automatically install compatible versions of all dependencies.

## Parameters

Several parameters are available to customize the behavior of the pipeline.
In addition, many of these parameters are also available as configuration options configurable within `ps-rule.yaml`.

Some of the most common parameters are listed below.
For a full list of parameters see the readme for [GitHub Actions][6] or [Azure Pipelines][7].

  [6]: https://github.com/microsoft/ps-rule#inputs
  [7]: https://github.com/microsoft/PSRule-pipelines/blob/main/docs/tasks.md#ps-rule-assert

### Limiting input to a specific path

You can use the `inputPath` parameter to limit the analysis to a specific path.

!!! Tip
    The `inputPath` parameter only accepts a relative path.
    For example: `azure/modules/` if you have a `azure/modules/` directory in the root of your repository.
    Becareful not to specify a leading `/` such as `/azure/modules/`.
    On Linux `/` is the root directory, which makes this a fully qualified path instead of a relative path.

=== "GitHub Actions"

    ```yaml hl_lines="6"
    # Analyze Azure resources using PSRule for Azure
    - name: Analyze Azure template files
      uses: microsoft/ps-rule@v2.4.2
      with:
        modules: 'PSRule.Rules.Azure'
        inputPath: azure/modules/
    ```

=== "Azure Pipelines"

    ```yaml hl_lines="6"
    # Analyze Azure resources using PSRule for Azure
    - task: ps-rule-assert@2
      displayName: Analyze Azure template files
      inputs:
        modules: 'PSRule.Rules.Azure'
        inputPath: azure/modules/
    ```

### Configuring a baseline

You can set the `baseline` parameter to specify the name of a baseline to use.
A baseline is a set of rules and configuration.
PSRule for Azure ships with multiple baselines to choose from.
See [working with baselines][8] for more information.

  [8]: working-with-baselines.md

=== "GitHub Actions"

    ```yaml hl_lines="6"
    # Analyze Azure resources using PSRule for Azure
    - name: Analyze Azure template files
      uses: microsoft/ps-rule@v2.4.2
      with:
        modules: 'PSRule.Rules.Azure'
        baseline: Azure.GA_2022_06
    ```

=== "Azure Pipelines"

    ```yaml hl_lines="6"
    # Analyze Azure resources using PSRule for Azure
    - task: ps-rule-assert@2
      displayName: Analyze Azure template files
      inputs:
        modules: 'PSRule.Rules.Azure'
        baseline: Azure.GA_2022_06
    ```

### Adding additional modules

You can add additional modules to the `modules` parameter by using comma (`,`) separating each module name.

=== "GitHub Actions"

    ```yaml hl_lines="5"
    # Analyze Azure resources using PSRule for Azure
    - name: Analyze Azure template files
      uses: microsoft/ps-rule@v2.4.2
      with:
        modules: 'PSRule.Rules.Azure,PSRule.Monitor'
    ```

=== "Azure Pipelines"

    ```yaml hl_lines="5"
    # Analyze Azure resources using PSRule for Azure
    - task: ps-rule-assert@2
      displayName: Analyze Azure template files
      inputs:
        modules: 'PSRule.Rules.Azure,PSRule.Monitor'
    ```

### Outputting results

You can configure PSRule to output results into a file by using the `outputFormat` and `outputPath` parameters.
For details on the formats that are supported see [analysis output][9].

=== "GitHub Actions"

    ```yaml hl_lines="6-7"
    # Analyze Azure resources using PSRule for Azure
    - name: Analyze Azure template files
      uses: microsoft/ps-rule@v2.4.2
      with:
        modules: 'PSRule.Rules.Azure'
        outputFormat: Sarif
        outputPath: reports/ps-rule-results.sarif
    ```

=== "Azure Pipelines"

    ```yaml hl_lines="6-7"
    # Analyze Azure resources using PSRule for Azure
    - task: ps-rule-assert@2
      displayName: Analyze Azure template files
      inputs:
        modules: 'PSRule.Rules.Azure'
        outputFormat: Sarif
        outputPath: reports/ps-rule-results.sarif
    ```

  [9]: https://microsoft.github.io/PSRule/v2/analysis-output/

## Configuration

Configuration options for PSRule for Azure are set within the `ps-rule.yaml` file.
To set options, create a new file named `ps-rule.yaml` in the root directory of your repository.

!!! Tip
    This file should be committed to your repository so it is available when your pipeline runs.

### Expand template parameter files

[:octicons-book-24: Docs][1]

PSRule for Azure can automatically expand Azure template parameter files.
When enabled, PSRule for Azure automatically resolves parameter and template file context at runtime.

To enabled this feature, set the `Configuration.AZURE_PARAMETER_FILE_EXPANSION` option to `true`.
This option can be set within the `ps-rule.yaml` file.

```yaml title="ps-rule.yaml"
configuration:
  # Enable automatic expansion of Azure parameter files
  AZURE_PARAMETER_FILE_EXPANSION: true
```

  [1]: setup/configuring-expansion.md#parameter-file-expansion

### Expand Bicep source files

[:octicons-book-24: Docs][2]

PSRule for Azure can automatically expand Bicep source files.
When enabled, PSRule for Azure automatically expands and analyzes Azure resource from `.bicep` files.

To enabled this feature, set the `Configuration.AZURE_BICEP_FILE_EXPANSION` option to `true`.
This option can be set within the `ps-rule.yaml` file.

```yaml title="ps-rule.yaml"
configuration:
  # Enable automatic expansion of bicep source files
  AZURE_BICEP_FILE_EXPANSION: true
```

  [2]: setup/configuring-expansion.md#bicep-source-expansion

### Ignoring rules

To prevent a rule executing you can either:

- **Exclude** &mdash; The rule is not executed for any resource.
- **Suppress** &mdash; The rule is not executed for a specific resource by name.

To exclude a rule, set `Rule.Exclude` option within the `ps-rule.yaml` file.

[:octicons-book-24: Docs][3]

```yaml title="ps-rule.yaml"
rule:
  exclude:
  # Ignore the following rules for all resources
  - Azure.VM.UseHybridUseBenefit
  - Azure.VM.Standalone
```

To suppress a rule, set `Suppression` option within the `ps-rule.yaml` file.

[:octicons-book-24: Docs][4]

```yaml title="ps-rule.yaml"
suppression:
  Azure.AKS.AuthorizedIPs:
  # Exclude the following externally managed AKS clusters
  - aks-cluster-prod-eus-001
  Azure.Storage.SoftDelete:
  # Exclude the following non-production storage accounts
  - storagedeveus6jo36t
  - storagedeveus1df278
```

!!! tip
    Use comments within `ps-rule.yaml` to describe the reason why rules are excluded or suppressed.
    Meaningful comments help during peer review within a Pull Request (PR).
    Also consider including a date if the exclusions or suppressions are temporary.

  [3]: https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Options/#ruleexclude
  [4]: https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Options/#suppression

### Advanced configuration

[:octicons-book-24: Docs][5]

PSRule for Azure comes with many configuration options.
The setup section explains in detail how to configure each option.

  [5]: setup/configuring-options.md
