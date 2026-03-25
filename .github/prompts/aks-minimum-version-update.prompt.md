AKS Minimum Version - Update Instructions

Purpose

A concise guide to update the repository's AKS minimum Kubernetes version (configuration, docs, tests) while preserving baselines.

Steps

1. Branch
- Create a feature branch: `git checkout -b <your-user>/bump-aks-minimum-1.33.7`

2. Config
- Edit `src/PSRule.Rules.Azure/rules/Config.Rule.yaml` and set:
  - `AZURE_AKS_CLUSTER_MINIMUM_VERSION: '1.33.7'`

3. Find & Update
- Search the repo for the old version and the config key:
  - `git grep -n "1.32.7"`
  - `git grep -n "AZURE_AKS_CLUSTER_MINIMUM_VERSION"`
- Update matching documentation, examples, and rule pages to `1.33.7` (notably `docs/examples/` and `docs/en/rules/`).

4. Tests & Fixtures
- Update unit tests and fixtures under `tests/PSRule.Rules.Azure.Tests/`:
  - Replace `kubernetesVersion` / `orchestratorVersion` values in JSON/Bicep fixtures.
  - Update assertion strings to reference the new constraint `>=1.33.7`.
- Prefer targeted small edits for large JSON fixtures to avoid large-patch failures.

5. Baselines (Important)
- Do NOT change baseline files (e.g., `src/PSRule.Rules.Azure/rules/Baseline.Rule.yaml`).
- Quick check: `git checkout -- src/PSRule.Rules.Azure/rules/Baseline.Rule.yaml` if you accidentally modify it.

6. Verify
- Run unit tests locally (may take time):

PowerShell (recommended):

Invoke-Build Test -AssertStyle Client

Or run the VS Code task `test`.

- Optionally run analyzer: `Invoke-Build Analyze`.

7. Changelog & PR
- Add a short changelog entry in `docs/changelog.md` under Unreleased mentioning the bump and that baselines were not updated.

Example:

```
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to use `1.33.7` as the minimum version by @BernieWhite.
      [#nnnn](https://github.com/Azure/PSRule.Rules.Azure/issues/nnnn)
```

Notes & Tips

- If a single large JSON patch fails, split edits into smaller targeted apply_patch operations.
- Run `git status` frequently to ensure baselines remain untouched.
- Include a link in the PR description to the related issue or changelog entry.
