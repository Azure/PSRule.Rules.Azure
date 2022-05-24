# Azure.AppService.IsWebApp

## SYNOPSIS

Azure App Services web apps.

## DESCRIPTION

Use this selector to filter rules to only run against web apps.

## EXAMPLES

### Configure with YAML-based rules

- Use the `with` property to set `PSRule.Rules.Azure\Azure.AppService.IsWebApp`.

```yaml
---
# Synopsis: An example rule.
apiVersion: github.com/microsoft/PSRule/v1
kind: Rule
metadata:
  name: Local.MyRule
spec:
  with:
  - PSRule.Rules.Azure\Azure.AppService.IsWebApp
  condition:
    # Rule logic goes here
```

### Configure with JSON-based rules

- Use the `with` property to set `PSRule.Rules.Azure\Azure.AppService.IsWebApp`.

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
            "PSRule.Rules.Azure\\Azure.AppService.IsWebApp"
        ],
        "condition": {
            // Rule logic goes here
        }
    }
}
```

### Configure with PowerShell-based rules

- Use the `-With` parameter to set `PSRule.Rules.Azure\Azure.AppService.IsWebApp`.

```powershell
# Synopsis: An example rule.
Rule 'Local.MyRule' -With 'PSRule.Rules.Azure\Azure.AppService.IsWebApp' {
  # Rule logic goes here
}
```
