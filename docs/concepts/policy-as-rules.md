---
description: This topic covers using policy as rules which allows you to use Azure Policy as rules to test Infrastructure as Code.
author: BernieWhite
---

# Policy as rules

PSRule for Azure allows you to export your current Azure Policy assignments out as rules to enforce controls during development.
This allows you to:

- **Reuse controls** &mdash; that have already deployed with implementation of guardrails in your environment.
  For example: Azure Cloud Adoption Framework or regulatory compliance standards.
- **Reduce deployment issues** &mdash; by identifying Azure Policy controls that could prevent a deployment from succeeding.

!!! Abstract
    This topic covers using _policy as rules_ which allows you to use Azure Policy as rules to test Infrastructure as Code.

!!! Experimental "Experimental - [Learn more][1]"
    _Policy as rules_ are a work in progress.
    As always if you find bugs/ errors or if something just doesn't work as your expect it to, please let us know.
    You can log a bug on GitHub or [provide feedback here][2].

  [1]: versioning.md#experimental-features
  [2]: https://github.com/Azure/PSRule.Rules.Azure/discussions/1345

## Limitations

This feature does not support:

- **Resource provider modes** &mdash; evaluate data plane information exposed at runtime.
  Policies that target resource provider modes are automatically ignored.
- **Disabled policies** &mdash; Policy definitions with the effect `Disabled` are ignored.
- **Unassigned policies** &mdash; Only policy definitions assigned to a scope are exported.
- **Policies that check for assessment status** &mdash; Some policies use additional detection tools to check for compliance.
  Policies that check for assessment status are ignored.
- **Importing rules** &mdash; Rules generated from policy assignments cannot be imported back into Azure Policy.

## Using policy as rules

Using _policy as rules_ is a two step process:

1. Export assignment data from Azure.
2. Convert assignments to rules.

### Export assignment data

Run `Export-AzPolicyAssignmentData` to export assignments from Azure to an `*.assignment.json` file.

Key points:

- Before running this command, connect to an Azure subscription by installing the `Az` PowerShell module and using `Connect-AzAccount`.
- This command has no required parameters, and by default will export all assignments from you current Azure subscription.
  You can change the current Azure subscription by using `Set-AzContext`.

### Convert assignments to rules

Run `Export-AzPolicyAssignmentRuleData` to convert assignments to rules.
To run this command an `-AssignmentFile` parameter with the path to the assignment JSON file generated in the previous step.

After the command completes a new file `*.Rule.jsonc` should be generated containing generated rules.
