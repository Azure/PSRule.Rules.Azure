# Azure.Resource.SupportsTags

## SYNOPSIS

Resources that supports tags.

## DESCRIPTION

Use this selector to filter rules to only run against resources that support tags.

## EXAMPLES

### Configure with YAML-based rules

- Use the `with` property to set `PSRule.Rules.Azure\Azure.Resource.SupportsTags`.

```yaml
---
# Synopsis: An example rule.
apiVersion: github.com/microsoft/PSRule/v1
kind: Rule
metadata:
  name: Local.MyRule
spec:
  with:
  - PSRule.Rules.Azure\Azure.Resource.SupportsTags
  condition:
    # Rule logic goes here
```

### Configure with JSON-based rules

- Use the `with` property to set `PSRule.Rules.Azure\Azure.Resource.SupportsTags`.

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
            "PSRule.Rules.Azure\\Azure.Resource.SupportsTags"
        ],
        "condition": {
            // Rule logic goes here
        }
    }
}
```

### Configure with PowerShell-based rules

- Use the `-With` parameter to set `PSRule.Rules.Azure\Azure.Resource.SupportsTags`.

```powershell
# Synopsis: An example rule.
Rule 'Local.MyRule' -With 'PSRule.Rules.Azure\Azure.Resource.SupportsTags' {
  # Rule logic goes here
}
```
