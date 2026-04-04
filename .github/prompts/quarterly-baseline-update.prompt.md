Quarterly Baseline Update Instructions

Purpose

A concise guide to add a new quarterly baseline (e.g. `Azure.GA_2026_03`, `Azure.Preview_2026_03`, `Azure.CAF_2026_03`) and mark the previous quarter's baselines as obsolete.

Quarterly baselines are released every three months (March, June, September, December) for each year.
Baseline names follow the pattern `Azure.GA_yyyy_mm` and `Azure.Preview_yyyy_mm`.

Steps

1. Branch
- Create a feature branch: `git checkout -b <your-user>/quarterly-baseline-yyyy-mm`

2. Determine the new baseline period
- The new period follows the pattern `yyyy_mm` (e.g. `2026_03` for March 2026).
- The previous baseline (to mark obsolete) is the one that was previously `Latest` (no `obsolete` annotation).

3. Determine the current module version
- Look at recent changelog entries in `docs/changelog.md` for the current `v1.x.x` release version.
- The new baselines use `moduleVersion: v1.x.x` set to the upcoming release version.
- To find the next version: check the current version in the most recently released baseline and increment appropriately.

4. Check for the current AKS minimum version
- Look at `src/PSRule.Rules.Azure/rules/Config.Rule.yaml` for `AZURE_AKS_CLUSTER_MINIMUM_VERSION`.
- Use this value in the new baselines.

5. Update `src/PSRule.Rules.Azure/rules/Baseline.Rule.yaml`
- Mark the previous latest GA and Preview baselines as obsolete by adding `obsolete: true` to their `annotations` block.
  Example — change:
  ```yaml
  annotations:
    export: true
    moduleVersion: v1.47.0
  ```
  to:
  ```yaml
  annotations:
    export: true
    moduleVersion: v1.47.0
    obsolete: true
  ```
- Append two new baseline entries at the end of the file (GA and Preview) following the existing pattern.
  Each new baseline includes all prior ruleSets plus the new `yyyy_mm` entry.

  Example for `Azure.GA_2026_03`:
  ```yaml
  ---
  # Synopsis: Include rules released March 2026 or prior for Azure GA features.
  apiVersion: github.com/microsoft/PSRule/v1
  kind: Baseline
  metadata:
    name: Azure.GA_2026_03
    annotations:
      export: true
      moduleVersion: v1.48.0
  spec:
    configuration:
      # Configure minimum AKS cluster version
      AZURE_AKS_CLUSTER_MINIMUM_VERSION: '1.33.7'
    rule:
      tag:
        release: GA
        ruleSet:
        - '2020_06'
        # ... all prior ruleSets ...
        - '2025_12'
        - '2026_03'
  ```

  Example for `Azure.Preview_2026_03` (same but `release: preview`):
  ```yaml
  ---
  # Synopsis: Include rules released March 2026 or prior for Azure preview only features.
  apiVersion: github.com/microsoft/PSRule/v1
  kind: Baseline
  metadata:
    name: Azure.Preview_2026_03
    annotations:
      export: true
      moduleVersion: v1.48.0
  spec:
    configuration:
      # Configure minimum AKS cluster version
      AZURE_AKS_CLUSTER_MINIMUM_VERSION: '1.33.7'
    rule:
      tag:
        release: preview
        ruleSet:
        - '2020_06'
        # ... all prior ruleSets ...
        - '2025_12'
        - '2026_03'
  ```

6. Update `src/PSRule.Rules.Azure/rules/CAF.Rule.yaml`
- Append a new `Azure.CAF_yyyy_mm` baseline at the end of the file.
- Copy the configuration from the most recent `Azure.CAF_*` baseline and add the new `yyyy_mm` ruleSet.
- Update `moduleVersion` to the new version.

  Example for `Azure.CAF_2026_03`:
  ```yaml
  ---
  # Synopsis: Includes rules related to Azure CAF based on a March 2026 snapshot.
  apiVersion: github.com/microsoft/PSRule/v1
  kind: Baseline
  metadata:
    name: Azure.CAF_2026_03
    annotations:
      taxonomy: Azure.CAF
      export: true
      moduleVersion: v1.48.0
      experimental: true
  spec:
    rule:
      tag:
        release: GA
        ruleSet:
        - '2020_06'
        # ... all prior ruleSets ...
        - '2025_12'
        - '2026_03'
      labels:
        Azure.CAF: '*'
    configuration:
      # Same configuration as the previous CAF baseline
      AZURE_VNET_NAME_FORMAT: '^vnet-'
      # etc.
  ```

7. Update unit tests
- Edit `tests/PSRule.Rules.Azure.Tests/Azure.Baseline.Tests.ps1`.
- Add two new `It` blocks at the end of the `Context 'Rule'` section for `Azure.GA_yyyy_mm` and `Azure.Preview_yyyy_mm`.
- To determine the correct rule count, build the module and run:
  ```powershell
  Import-Module ./out/modules/PSRule.Rules.Azure -Force
  $ga = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2026_03' -WarningAction Ignore)
  ($ga | Where-Object { $_.Tag.release -in 'GA' }).Length
  $preview = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2026_03' -WarningAction Ignore)
  ($preview | Where-Object { $_.Tag.release -in 'preview' }).Length
  ```
- Use the output counts in the test assertions.

  Example:
  ```powershell
  It 'With Azure.GA_2026_03' {
      $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2026_03' -WarningAction Ignore);
      $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
      $filteredResult | Should -Not -BeNullOrEmpty;
      $filteredResult.Length | Should -Be 517;
  }

  It 'With Azure.Preview_2026_03' {
      $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2026_03' -WarningAction Ignore);
      $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
      $filteredResult | Should -Not -BeNullOrEmpty;
      $filteredResult.Length | Should -Be 8;
  }
  ```

8. Build and verify
- Build the module:
  ```powershell
  Invoke-Build BuildModule -File pipeline.build.ps1 -Configuration Debug -Build '0.0.1'
  ```
- Run the baseline tests:
  ```powershell
  Import-Module ./out/modules/PSRule.Rules.Azure -Force
  Invoke-Pester tests/PSRule.Rules.Azure.Tests/Azure.Baseline.Tests.ps1 -Tag Baseline
  ```
- All tests should pass.

9. Changelog & PR
- Add a changelog entry in `docs/changelog.md` under the `## Unreleased` section.

  Example:
  ```
  - New features:
    - Added March 2026 baselines `Azure.GA_2026_03`, `Azure.Preview_2026_03`, and `Azure.CAF_2026_03` by @BernieWhite.
      [#nnnn](https://github.com/Azure/PSRule.Rules.Azure/issues/nnnn)
      - Includes rules released before or during March 2026.
      - Marked `Azure.GA_2025_12` and `Azure.Preview_2025_12` baselines as obsolete.
  ```

Notes & Tips

- Do NOT update auto-generated baseline documentation files in `docs/en/baselines/` — these are regenerated automatically.
- The `docs/en/baselines/index.md` and individual baseline `.md` files have `generated: true` in their front matter.
- The rule count for a new quarterly baseline is the same as the previous one if no new rules with the new `ruleSet` tag have been added yet.
- After adding new rules tagged with the new `ruleSet` (e.g. `2026_03`), the baseline test counts must be updated accordingly.
