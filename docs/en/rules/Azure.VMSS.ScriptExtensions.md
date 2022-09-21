---
reviewed: 2022-07-09
severity: Important
pillar: Security
category: Secrets
resource: Virtual Machine Scale Sets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VMSS.ScriptExtensions/
---

# Securely pass secrets to Custom Script Extensions for Virtual Machine Scale Sets

## SYNOPSIS

Custom Script Extensions scripts that reference secret values must use the protectedSettings.

## DESCRIPTION

Virtual Machines Scale Sets support the ability to execute custom scripts
on launch. This can be configured via user data and custom script extensions.
When the template is rendered, anything in the settings section will
be rendered in clear text. To ensure they're kept secret, use the protectedSettings
section instead.

## RECOMMENDATION

Recommendation

## EXAMPLES

Instead of using `properties.extensionProfile.extensions.settings` use
`properties.extensionProfile.extensions.protectedSettings`.

### Configure with Azure template

```json
"extensionProfile": {
  "extensions": [
    {
      "name": "customScript",
      "properties": {
          "publisher": "Microsoft.Compute",
          "protectedSettings": {
              "commandToExecute": "Write-Output 'example'"
          },
          "typeHandlerVersion": "1.8",
          "autoUpgradeMinorVersion": true,
          "type": "CustomScriptExtension"
      }
    }
  ]
}
```

### Configure with Bicep

```Bicep
extensionProfile: {
  extensions: [
    {
      name: 'customScript'
      properties: {
        publisher: 'Microsoft.Compute'
        protectedSettings: {
          commandToExecute: 'Write-Output "example"'
        },
        typeHandlerVersion: '1.8'
        autoUpgradeMinorVersion: true
        type: 'CustomScriptExtension'
      }
    }
  ]
}
```

## LINKS

- [Azure deployment references](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets/extensions?pivots=deployment-language-bicep)
- [Azure VMSS Extensions Overview](https://learn.microsoft.com/azure/virtual-machines/extensions/overview)
