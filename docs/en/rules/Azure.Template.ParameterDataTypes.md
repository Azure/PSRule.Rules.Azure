---
severity: Important
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.ParameterDataTypes/
---

# Default should match type

## SYNOPSIS

Set the parameter default value to a value of the same type.

## DESCRIPTION

Azure Resource Manager (ARM) template support parameters with a range of types, including:

- `bool`
- `int`
- `string`
- `array`
- `object`
- `secureString`
- `secureObject`

When including a `defaultValue`, the default value should match the same type at the `type` property.
For example:

```json
{
  "boolParam": {
    "type": "bool",
    "defaultValue": false
  },
  "intParam": {
    "type": "int",
    "defaultValue": 5
  },
  "stringParam": {
    "type": "string",
    "defaultValue": "test-rg"
  },
  "arrayParam": {
    "type": "array",
    "defaultValue": [ 1, 2, 3 ]
  },
  "objectParam": {
    "type": "object",
    "defaultValue": {
      "one": "a",
      "two": "b"
      }
  }
}
```

## RECOMMENDATION

Consider updating the parameter default value to a value of the same type.

## LINKS

- [Data types](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-syntax#data-types)
- [Release deployment](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
