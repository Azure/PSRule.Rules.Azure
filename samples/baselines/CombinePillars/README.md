---
author: BernieWhite
type: Baseline
---

# Combine WAF pillars

A baseline that combines GA rules only from the Security and Reliability pillars.

## Summary

This sample shows how to create a baseline that combines two WAF pillars (Security/ Reliability) into a single baseline.
It also shows how to exclude rules from the baseline by excluding `Azure.ACR.GeoReplica` (`AZR-000004`).

## Usage

- Copy the `CombinePillars.Rule.yaml` file to your default include path `.ps-rule/`.
- Set a custom binding configuration as specified [here](https://azure.github.io/PSRule.Rules.Azure/customization/using-custom-rules/#set-binding-configuration).
- Use the baseline by:
  - Using the `-Baseline` parameter to specify the baseline from PowerShell using `Assert-PSRule` or `Invoke-PSRule`.
  - Using the `baseline:` input in GitHub Actions or Azure Pipelines pipeline YAML configurations.

## References

- [Set binding configuration](https://azure.github.io/PSRule.Rules.Azure/customization/using-custom-rules/#set-binding-configuration)
- [Configuring a baseline](https://azure.github.io/PSRule.Rules.Azure/creating-your-pipeline/#configuring-a-baseline)
- [Baseline reference](https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Baseline/)
- [Baselines](https://microsoft.github.io/PSRule/v2/concepts/baselines/)
