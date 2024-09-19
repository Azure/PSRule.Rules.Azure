---
reviewed: 2024-09-20
online version: https://github.com/Azure/PSRule.Rules.Azure/blob/main/.ps-rule/en/Rule.RuleSet.md
---

# Valid ruleSet tag

## SYNOPSIS

Rules must be tagged with the next rule set.

## DESCRIPTION

Rules are released on a regular basis.
This is used to include rules in quarterly baselines.

The rule set tag identifies the quarter that the rule was first released.
New rules are included in the next quarterly baseline.
i.e. (YYYY_03, YYYY_06, YYYY_09, YYYY_12)

When updating an existing rule that introduces new significant changes to validation conditions,
the ruleSet should be bumped to the next quarterly baseline.

## RECOMMENDATION

Set the `ruleSet` tag to the next rule set for each rule on creation.

## EXAMPLES

### Configure with YAML rules

To create a rule that passes tests:

- Set the `tags.ruleSet` property.

For example:

```yaml
---
# Synopsis: Consider configuring a managed identity for each API Management instance.
apiVersion: github.com/microsoft/PSRule/v1
kind: Rule
metadata:
  name: Azure.APIM.ManagedIdentity
  ref: AZR-000053
  tags:
    release: GA
    ruleSet: 2024_09
spec:
  type:
  - Microsoft.ApiManagement/service
  condition:
    field: Identity.Type
    in:
    - SystemAssigned
    - UserAssigned
    - SystemAssigned, UserAssigned
```

### Configure with PowerShell rules

To create a rule that passes tests:

- Set the `ruleSet` value in the `-Tag` hashtable property.

For example:

```powershell
# Synopsis: Regularly remove unused resources to reduce costs.
Rule 'Azure.ADX.Usage' -Ref 'AZR-000011' -Type 'Microsoft.Kusto/clusters' -If { IsExport } -With 'Azure.ADX.IsClusterRunning' -Tag @{ release = 'GA'; ruleSet = '2024_09'; } {
    $items = @(GetSubResources -ResourceType 'Microsoft.Kusto/clusters/databases');
    $Assert.GreaterOrEqual($items, '.', 1);
}
```

## LINKS

- [Contributing to PSRule for Azure](https://github.com/Azure/PSRule.Rules.Azure/blob/main/CONTRIBUTING.md)
