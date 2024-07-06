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

  [1]: ../versioning.md#experimental-features
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

!!! Bug
    Currently a known incompatibility exists with 7.x of `Az.Resources` which introduced a breaking change.
    Please use `Az.Resources` >= v6.7.0 and < v7.0.0.
    For more information see [Issues with Az.Resources](../troubleshooting.md#issues-with-azresources)

For example:

```powershell title="PowerShell"
# Install and import required modules.
Install-Module Az.Resources -RequiredVersion '6.7.0' -Force -Scope CurrentUser
Import-Module Az.Resources -RequiredVersion '6.7.0'
Import-Module PSRule.Rules.Azure

# Connect to Azure
Connect-AzAccount
Set-AzContext -Subscription '<subscriptionId>'

# Export assignments
Export-AzPolicyAssignmentData
```

### Convert assignments to rules

Run `Export-AzPolicyAssignmentRuleData` to convert assignments to rules.
To run this command an `-AssignmentFile` parameter with the path to the assignment JSON file generated in the previous step.

After the command completes a new file `*.Rule.jsonc` should be generated containing generated rules.

For example:

```powershell title="PowerShell"
Export-AzPolicyAssignmentRuleData -AssignmentFile '.\<subscriptionId>.assignment.json'
```

## Customizing the generated rules

PSRule for Azure allows you to:

- **Set a name prefix** &mdash; to help identify generated rules.
  By default, generated rules and baselines are prefixed with `Azure`.
  To change the prefix:
  - Use the `-RulePrefix` parameter when running `Export-AzPolicyAssignmentRuleData`. _OR_
  - Set the `AZURE_POLICY_RULE_PREFIX` configuration option in `ps-rule.yaml`.
- **Exclude specific policies** &mdash; by setting the `AZURE_POLICY_IGNORE_LIST` configuration option in `ps-rule.yaml`.
  This option allows you to prevent specific policies from being exported as rules.

For example:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_POLICY_RULE_PREFIX: MyOrg
  AZURE_POLICY_IGNORE_LIST:
  - /providers/Microsoft.Authorization/policyDefinitions/1f314764-cb73-4fc9-b863-8eca98ac36e9
  - /providers/Microsoft.Authorization/policyDefinitions/b54ed75b-3e1a-44ac-a333-05ba39b99ff0
```

## Generated baseline

<!-- module:version v1.33.0 -->

When exporting policies, PSRule for Azure will automatically generate a baseline including any generated rules.
By default, this baseline is called `Azure.PolicyBaseline.All`.
If you change the prefix of generated rules the baseline will be named `<Prefix>.PolicyBaseline.All`.

See [Using baselines](../working-with-baselines.md#using-baselines) for examples on how to use a baseline in a run.

## Duplicate policies

<!-- module:version v1.33.0 -->

When exporting policies, you may encounter definitions that are duplicates of existing rules shipped with PSRule for Azure.
By default, built-in Azure policies that are duplicates of existing rules are ignored.
Additionally, PSRule for Azure will automatically switch in existing rules into the generated baseline.

!!! Note
    This only applies to built-in Azure policies that are duplicates of existing rules.
    Custom policies are not effected.

    The list of built-in policies that are duplicates can be viewed [here][3].
    If you believe a policy is missing from this list, please [open an issue][4].

    [3]: https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/policy-ignore.json
    [4]: https://github.com/Azure/PSRule.Rules.Azure/issues/new/choose

This allows you to:

- Focus on policies that are unique to your environment and not already covered by PSRule for Azure.
- Benefit from the additional references and examples provided by PSRule for Azure.
- Reduce noise reporting the same issue multiple times.

To override this behavior use the `-KeepDuplicates` parameter switch when running `Export-AzPolicyAssignmentRuleData`.
