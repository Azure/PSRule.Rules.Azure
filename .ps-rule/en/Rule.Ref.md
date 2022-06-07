---
reviewed: 2022-06-07
online version: https://github.com/Azure/PSRule.Rules.Azure/blob/main/.ps-rule/en/Rule.Ref.md
---

# Opaque identifier

## SYNOPSIS

Rules must use a valid opaque identifier.

## DESCRIPTION

Each rule must use an opaque identifier using the format `AZR-nnnnnnn`.
Where `nnnnnn` is a sequential number from `000001`.

## RECOMMENDATION

Configure a unique reference opaque identifier for each rule.

## EXAMPLES

### Configure with YAML rules

To create a rule that passes tests:

- Set the `ref` rule property.

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
    ruleSet: 2020_06
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

- Set the `-Ref` rule parameter.

For example:

```powershell
# Synopsis: Regularly remove unused resources to reduce costs.
Rule 'Azure.ADX.Usage' -Ref 'AZR-000011' -Type 'Microsoft.Kusto/clusters' -If { IsExport } -With 'Azure.ADX.IsClusterRunning' -Tag @{ release = 'GA'; ruleSet = '2022_03'; } {
    $items = @(GetSubResources -ResourceType 'Microsoft.Kusto/clusters/databases');
    $Assert.GreaterOrEqual($items, '.', 1);
}
```

## LINKS

- [Contributing to PSRule for Azure](https://github.com/Azure/PSRule.Rules.Azure/blob/main/CONTRIBUTING.md)
