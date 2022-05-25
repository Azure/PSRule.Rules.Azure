# Azure.AppService.IsLogicApp

## SYNOPSIS

Single tenanted Logic Apps.

## DESCRIPTION

Use this selector to filter rules to only run against Logic Apps with the Standard SKU.

## EXAMPLES

### Configure with YAML-based rules

- Use the `with` property to set `PSRule.Rules.Azure\Azure.AppService.IsLogicApp`.

```yaml
---
# Synopsis: An example rule.
apiVersion: github.com/microsoft/PSRule/v1
kind: Rule
metadata:
  name: Local.MyRule
spec:
  with:
  - PSRule.Rules.Azure\Azure.AppService.IsLogicApp
  condition:
    # Rule logic goes here
```

### Configure with JSON-based rules

- Use the `with` property to set `PSRule.Rules.Azure\Azure.AppService.IsLogicApp`.

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
            "PSRule.Rules.Azure\\Azure.AppService.IsLogicApp"
        ],
        "condition": {
            // Rule logic goes here
        }
    }
}
```

### Configure with PowerShell-based rules

- Use the `-With` parameter to set `PSRule.Rules.Azure\Azure.AppService.IsLogicApp`.

```powershell
# Synopsis: An example rule.
Rule 'Local.MyRule' -With 'PSRule.Rules.Azure\Azure.AppService.IsLogicApp' {
  # Rule logic goes here
}
```
