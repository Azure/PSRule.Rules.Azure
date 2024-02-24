# Azure.FrontDoor.IsStandardOrPremium

## SYNOPSIS

Azure Front Door profiles using the Standard or Premium SKU.

## DESCRIPTION

Use this selector to filter rules to only run against Azure Front Door profiles using the Standard or Premium SKU.

## EXAMPLES

### Configure with YAML-based rules

- Use the `with` property to set `PSRule.Rules.Azure\Azure.FrontDoor.IsStandardOrPremium`.

```yaml
---
# Synopsis: An example rule.
apiVersion: github.com/microsoft/PSRule/v1
kind: Rule
metadata:
  name: Local.MyRule
spec:
  with:
  - PSRule.Rules.Azure\Azure.FrontDoor.IsStandardOrPremium
  condition:
    # Rule logic goes here
```

### Configure with JSON-based rules

- Use the `with` property to set `PSRule.Rules.Azure\Azure.FrontDoor.IsStandardOrPremium`.

```json
{
    // Synopsis: An example rule.
    "apiVersion": "github.com/microsoft/PSRule/v1",
    "kind": "Rule",
    "metadata": {
        "name": "Local.MyRule"
    },
    "spec": {
        "with": [
            "PSRule.Rules.Azure\\Azure.FrontDoor.IsStandardOrPremium"
        ],
        "condition": {
            // Rule logic goes here
        }
    }
}
```

### Configure with PowerShell-based rules

- Use the `-With` parameter to set `PSRule.Rules.Azure\Azure.FrontDoor.IsStandardOrPremium`.

```powershell
# Synopsis: An example rule.
Rule 'Local.MyRule' -With 'PSRule.Rules.Azure\Azure.FrontDoor.IsStandardOrPremium' {
  # Rule logic goes here
}
```
