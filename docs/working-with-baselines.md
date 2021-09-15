# Working with baselines

A baseline is a standard PSRule artifact that combines rules and configuration.
PSRule for Azure provides several baselines that can be referenced when running PSRule.

!!! Abstract
    This topic covers how to use baselines shipped with PSRule for Azure.

## Quarterly baselines

PSRule for Azure ships new rules on a monthly cadence.
As new rules are added, existing pipelines that previously passed may fail based on additional requirements.
It is generally expected that files committed to an integration branch such as `main` continue to pass.

PSRule for Azure addresses this through quarterly baselines that provide:

- **Greater consistency** &mdash; Quarterly baselines provide a stable checkpoint of rules to use.
  Each quarterly baseline includes rules for generally available (GA) Azure features to date.
  Rules released after the quarterly baseline are added to the next quarterly baseline.
  New quarterly baselines are released every three (3) months.
  Baselines are named `Azure.GA_yyyy_mm` based on the release year/ month.
- **Incremental adoption** &mdash; It may not be possibly to implement new rules immediately.
  Existing backlogs or timelines may make it impossible to add new requirements until a future sprint.
  In a future sprint, bump the quarterly baseline to the latest release to get the additional rules.

Considerations for adopting a quarterly baseline include:

- The quarterly baselines older than the latest are flagged as obsolete.
  Obsolete baselines can still be used, however will generate a warning.
- As Azure evolves there may be cases where a feature change means a rule is no longer required.
  In these cases, a rule may be removed from PSRule for Azure and any applicable baselines.
- Quarterly baselines to not included Azure features that are released under a public or private preview.
  To use rules for preview Azure features, you can use the `Azure.Preview` baseline.
  However, the `Azure.Preview` is not released quarterly it is updated as new rules are added.
  Alternatively, you can create a custom baseline.

!!! Important
    When using a quarterly baseline, by default PSRule will ignore custom/ standalone rules.
    To include custom rules, set the `Rule.IncludeLocal` option to `true`.
    This is described further in [including custom rules](#including-custom-rules).

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

## Using baselines

To use a baseline within a CI pipeline specify the baseline by name.
See [reference][1] for a list baselines shipped with PSRule for Azure.

=== "GitHub Actions"

    Update your GitHub Actions workflow by specifying `baseline: <name_of_baseline>`.

    ```yaml
    # Analyze Azure resources using PSRule for Azure
    - name: Analyze Azure template files
      uses: Microsoft/ps-rule@main
      with:
        modules: 'PSRule.Rules.Azure'
        baseline: 'Azure.GA_2021_09'
    ```

=== "Azure Pipelines"

    Update your Azure DevOps YAML pipeline by specifying `baseline: <name_of_baseline>`.

    ```yaml
    # Analyze Azure resources using PSRule for Azure
    - task: ps-rule-assert@0
      displayName: Analyze Azure template files
      inputs:
        inputType: repository
        modules: 'PSRule.Rules.Azure'
        baseline: 'Azure.GA_2021_09'
    ```

  [1]: en/baselines/Azure.All.md

## Creating baselines

To create your own baselines see the PSRule help topic [about_PSRule_Baseline][2].

  [2]: https://microsoft.github.io/PSRule/concepts/PSRule/en-US/about_PSRule_Baseline.html

## Including custom rules

:octicons-milestone-24: v1.8.0

The quarterly baselines shipped with PSRule for Azure target a subset of rules for GA Azure features.
When you specify a baseline, custom rules you create and store in `.ps-rule/` will be ignored by default.

To change this behavior, set the `Rule.IncludeLocal` option to `true`.
This option can be set in `ps-rule.yaml`.

```yaml
# YAML: Enable custom rules that don't exist in the baseline
rule:
  includeLocal: true
```

*[GA]: generally available
