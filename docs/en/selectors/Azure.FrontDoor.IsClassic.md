# AAzure.FrontDoor.IsClassic

## SYNOPSIS

Azure Front Door profiles using the Classic SKU.

## DESCRIPTION

Use this selector to filter rules to only run against Azure Front Door profiles using the Classic SKU.

## EXAMPLES

### Configure with YAML-based rules

- Use the `with` property to set `PSRule.Rules.Azure\Azure.FrontDoor.IsClassic`.

```yaml
---
# Synopsis: An example rule.
apiVersion: github.com/microsoft/PSRule/v1
kind: Rule
metadata:
  name: Local.MyRule
spec:
  with:
  - PSRule.Rules.Azure\Azure.FrontDoor.IsClassic
  condition:
    # Rule logic goes here
```

### Configure with JSON-based rules

- Use the `with` property to set `PSRule.Rules.Azure\Azure.FrontDoor.IsClassic`.

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
            "PSRule.Rules.Azure\\Azure.FrontDoor.IsClassic"
        ],
        "condition": {
            // Rule logic goes here
        }
    }
}
```

### Configure with PowerShell-based rules

- Use the `-With` parameter to set `PSRule.Rules.Azure\Azure.FrontDoor.IsClassic`.

```powershell
# Synopsis: An example rule.
Rule 'Local.MyRule' -With 'PSRule.Rules.Azure\Azure.FrontDoor.IsClassic' {
  # Rule logic goes here
}
```
