---
author: BernieWhite
---

# Configuring options

PSRule for Azure comes with many configuration options.
Additionally, the PSRule engine includes several options that apply to all rules.
You can visit the [about_PSRule_Options][1] topic to read about general PSRule options.

  [1]: https://microsoft.github.io/PSRule/concepts/PSRule/en-US/about_PSRule_Options.html

## Setting options

Configuration options are set within the `ps-rule.yaml` file.
If you don't already have a `ps-rule.yaml` file you can create one in the root of your repository.

Configuration can be combined as indented keys.
Use comments to add context.
Here are some examples:

```yaml
requires:
  # Require a minimum of PSRule for Azure v1.4.1
  PSRule.Rules.Azure: '>=1.4.1'

configuration:
  # Enable parameter file expansion
  AZURE_PARAMETER_FILE_EXPANSION: true

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
