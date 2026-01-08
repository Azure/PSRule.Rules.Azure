---
reviewed: 2025-10-10
description: |
  A baseline is a standard PSRule artifact that combines rules and configuration.
  PSRule for Azure provides several built-in baselines that can be referenced when running PSRule.
---

# Working with baselines

A baseline is a standard PSRule artifact that combines rules and configuration.
PSRule for Azure provides several built-in baselines that can be referenced when running PSRule.
It is also possible to create your own custom baselines.

This topic covers how to use built-in baselines shipped with PSRule for Azure or custom baselines you define.

## Quarterly baselines

PSRule for Azure ships new rules typically on a monthly cadence.
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

## Pillar specific baselines

<!-- module:version v1.35.0 -->

Pillar specific baselines includes rules aligned to a specific Microsoft Azure Well-Architected Framework pillar.

Use these baselines to focus on improvement aligned to a specific area of the Azure Well-Architected Framework.
Only rules that related to GA Azure features are included in these baselines.
These baselines are best used for ad-hoc scans.

The following baselines are available:

- [Azure.Pillar.CostOptimization][4] &mdash; A baseline that only includes cost optimization rules.
- [Azure.Pillar.OperationalExcellence][5] &mdash; A baseline that only includes operational excellence rules.
- [Azure.Pillar.PerformanceEfficiency][6] &mdash; A baseline that only includes performance efficiency rules.
- [Azure.Pillar.Reliability][7] &mdash; A baseline that only includes reliability rules.
- [Azure.Pillar.Security][8] &mdash; A baseline that only includes security rules.
- [Azure.Pillar.Security.L1][9] &mdash; A baseline that only includes security rules at with maturity level 1.

  [4]: en/baselines/Azure.Pillar.CostOptimization.md
  [5]: en/baselines/Azure.Pillar.OperationalExcellence.md
  [6]: en/baselines/Azure.Pillar.PerformanceEfficiency.md
  [7]: en/baselines/Azure.Pillar.Reliability.md
  [8]: en/baselines/Azure.Pillar.Security.md
  [9]: en/baselines/Azure.Pillar.Security.L1.md

## Additional standard baselines

In additional to quarterly and pillar specific baselines, some additional baselines exist:

- `Azure.Default` &mdash; Includes rules for GA Azure features.
  This is the default baseline that is used when no baseline is specified.
  Rules for Azure features that are within the scope of a public or private preview are not included.
- `Azure.Preview` &mdash; Includes all rules for GA and preview Azure features.
- `Azure.All` &mdash; Includes all Azure rules shipped with PSRule for Azure.
  This is functionally the same as `Azure.Preview` however intended for internal use only.
- `Azure.MCSB.v1` &mdash; Includes rules related to Microsoft cloud security benchmark (MCSB) controls.
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
        baseline: 'Azure.GA_2025_12'
    ```

=== "Azure Pipelines"

    Update your Azure DevOps YAML pipeline by specifying `baseline: <name_of_baseline>`.

    ```yaml
    # Analyze Azure resources using PSRule for Azure
    - task: ps-rule-assert@2
      displayName: Analyze Azure template files
      inputs:
        modules: 'PSRule.Rules.Azure'
        baseline: 'Azure.GA_2025_12'
    ```

=== "PowerShell"

    Update your PowerShell command-line with `-Baseline <name_of_baseline>`.

    ```powershell title="With Assert-PSRule"
    Assert-PSRule -Format File -InputPath '.' -Module 'PSRule.Rules.Azure' -Baseline 'Azure.GA_2025_12'
    ```

    ```powershell title="With Invoke-PSRule"
    Invoke-PSRule -Format File -InputPath '.' -Module 'PSRule.Rules.Azure' -Baseline 'Azure.GA_2025_12'
    ```

  [1]: en/baselines/Azure.All.md

## Creating baselines

To create your own baselines see the PSRule help topic [about_PSRule_Baseline][2].

  [2]: https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Baseline/

## Including custom rules

<!-- module:version v1.8.0 -->

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
