# Azure.ServiceBus.IsPremium

## SYNOPSIS

Azure Service Bus premium namespaces.

## DESCRIPTION

Use this selector to filter rules to only run against premium Service Bus namespaces.

## EXAMPLES

### Configure with YAML-based rules

- Use the `with` property to set `PSRule.Rules.Azure\Azure.ServiceBus.IsPremium`.

```yaml
---
# Synopsis: An example rule.
apiVersion: github.com/microsoft/PSRule/v1
kind: Rule
metadata:
  name: Local.MyRule
spec:
  with:
  - PSRule.Rules.Azure\Azure.ServiceBus.IsPremium
  condition:
    # Rule logic goes here
```

### Configure with JSON-based rules

- Use the `with` property to set `PSRule.Rules.Azure\Azure.ServiceBus.IsPremium`.

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
            "PSRule.Rules.Azure\\Azure.ServiceBus.IsPremium"
        ],
        "condition": {
            // Rule logic goes here
        }
    }
}
```

### Configure with PowerShell-based rules

- Use the `-With` parameter to set `PSRule.Rules.Azure\Azure.ServiceBus.IsPremium`.

```powershell
# Synopsis: An example rule.
Rule 'Local.MyRule' -With 'PSRule.Rules.Azure\Azure.ServiceBus.IsPremium' {
  # Rule logic goes here
}
```
