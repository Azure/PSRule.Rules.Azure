---
description: This topic covers how to use the baselines shipped with PSRule for Azure.
---

# Working with baselines

A baseline is a standard PSRule artifact that combines rules and configuration.
PSRule for Azure provides several baselines that can be referenced when running PSRule.

!!! Abstract
    This topic covers how to use the baselines shipped with PSRule for Azure.

## Quarterly baselines

PSRule for Azure ships new rules on a monthly cadence.
As new rules are added, existing pipelines that previously passed may fail based on additional requirements.
It is generally expected that files committed to an integration branch such as `main` continue to pass.

PSRule for Azure addresses this through quarterly baselines that provide:

- **Greater consistency** &mdash; Quarterly baselines provide a stable checkpoint of rules to use.
  Each quarterly baseline includes rules for generally available (GA) and preview Azure features to date.
  Rules released after the quarterly baseline are added to the next quarterly baseline.
  New quarterly baselines are released every three (3) months.
  Baselines are named `Azure.GA_yyyy_mm` and `Azure.Preview_yyyy_mm` based on the release year/ month.
- **Incremental adoption** &mdash; It may not be possibly to implement new rules immediately.
  Existing backlogs or timelines may make it impossible to add new requirements until a future sprint.
  In a future sprint, bump the quarterly baseline to the latest release to get the additional rules.

Considerations for adopting a quarterly baseline include:

- The quarterly baselines older than the latest are flagged as obsolete.
  Obsolete baselines can still be used, however will generate a warning.
- As Azure evolves there may be cases where a feature change means a rule is no longer required.
  In these cases, a rule may be removed from PSRule for Azure and any applicable baselines.
- Separate quarterly baselines for Azure GA and preview features are provided.
  The baseline for GA features is named `Azure.GA_yyyy_mm` and preview features is named `Azure.Preview_yyyy_mm`.

!!! Important
    When using a quarterly baseline, by default PSRule will ignore custom/ standalone rules.
    To include custom rules, set the `Rule.IncludeLocal` option to `true`.
    This is described further in [including custom rules](#including-custom-rules).

!!! Note
    The preview quarterly baselines includes Azure features released under preview only.
    This is different from the `Azure.Preview` baseline which contains GA and preview features.

### Limitations

Quarterly baselines don't address all cases where a previously passing pipeline may fail, specifically:

- As bugs are identified they are corrected and shipped in the next minor or patch release.
  If the rule was not correctly working previously, failures may be generated after the fix.
  To workaround this you can either:
  - Create a temporary suppression to ignore the issue.
  - Install a previous version of the PSRule for Azure module.
- Rule configuration defaults change.
  Currently rule configuration defaults are not included in quarterly baselines.
  To workaround this, override the rule configuration option by setting the value in `ps-rule.yaml`.

## Additional standard baselines

In additional to quarterly baselines, some additional baselines exist:

- `Azure.Default` - Includes rules for GA Azure features.
  This is the default baseline that is used when no baseline is specified.
  Rules for Azure features that are within the scope of a public or private preview are not included.
- `Azure.Preview` - Includes rules for GA and preview Azure features.
- `Azure.All` - Includes all Azure rules shipped with PSRule for Azure.
  This is functionally the same as `Azure.Preview` however intended for internal use only.
- `Azure.MCSB.v1` - Includes rules related to Microsoft cloud security benchmark (MCSB) controls.
  This baseline is currently experimental and may change in future releases.
  You can learn more about MCSB within PSRule for Azure in the [Microsoft cloud security benchmark (MCSB)][3] topic.

  [3]: en/mcsb-v1.md

## Using baselines

To use a baseline within a CI pipeline specify the baseline by name.
See [reference][1] for a list baselines shipped with PSRule for Azure.

=== "GitHub Actions"

    Update your GitHub Actions workflow by specifying `baseline: <name_of_baseline>`.

    ```yaml
    # Analyze Azure resources using PSRule for Azure
    - name: Analyze Azure template files
      uses: microsoft/ps-rule@v2.9.0
      with:
        modules: 'PSRule.Rules.Azure'
        baseline: 'Azure.GA_2023_03'
    ```

=== "Azure Pipelines"

    Update your Azure DevOps YAML pipeline by specifying `baseline: <name_of_baseline>`.

    ```yaml
    # Analyze Azure resources using PSRule for Azure
    - task: ps-rule-assert@2
      displayName: Analyze Azure template files
      inputs:
        modules: 'PSRule.Rules.Azure'
        baseline: 'Azure.GA_2023_03'
    ```

=== "PowerShell"

    Update your PowerShell command-line with `-Baseline <name_of_baseline>`.

    ```powershell title="With Assert-PSRule"
    Assert-PSRule -Format File -InputPath '.' -Module 'PSRule.Rules.Azure' -Baseline 'Azure.GA_2023_03'
    ```

    ```powershell title="With Invoke-PSRule"
    Invoke-PSRule -Format File -InputPath '.' -Module 'PSRule.Rules.Azure' -Baseline 'Azure.GA_2023_03'
    ```

  [1]: en/baselines/Azure.All.md

## Creating baselines

To create your own baselines see the PSRule help topic [about_PSRule_Baseline][2].

  [2]: https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Baseline/

## Including custom rules

:octicons-milestone-24: v1.8.0

The quarterly baselines shipped with PSRule for Azure target a subset of rules for GA Azure features.
When you specify a baseline, custom rules you create and store in `.ps-rule/` will be ignored by default.

To change this behavior, set the `Rule.IncludeLocal` option to `true`.
This option can be set in `ps-rule.yaml`.

```yaml title="ps-rule.yaml"
# YAML: Enable custom rules that don't exist in the baseline
rule:
  includeLocal: true
```

*[GA]: generally available
