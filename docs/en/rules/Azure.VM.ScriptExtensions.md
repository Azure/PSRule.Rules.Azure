---
reviewed: 2022-07-09
severity: Important
pillar: Security
category: Secrets
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.ScriptExtensions/
---

# Securely pass secrets to Custom Script Extensions for Virtual Machine

## SYNOPSIS

Custom Script Extensions scripts that reference secret values must use the protectedSettings.

## DESCRIPTION

Virtual Machines support the ability to execute custom scripts
on launch. This can be configured via user data and custom script extensions.
When the template is rendered, anything in the settings section will
be rendered in clear text. To ensure they're kept secret, use the protectedSettings
section instead.

## RECOMMENDATION

Move the script in the `properties.settings` property to the `properties.protectedSettings` property.

## EXAMPLES

### Configure with Azure template

ARM

```json
{
  "type": "Microsoft.Compute/virtualMachines/extensions",
  "name": "installcustomscript",
  "apiVersion": "2015-06-15",
  "location": "australiaeast",
  "properties": {
    "publisher": "Microsoft.Azure.Extensions",
    "type": "CustomScript",
    "typeHandlerVersion": "2.0",
    "autoUpgradeMinorVersion": true,
    "protectedSettings": {
        "commandToExecute": "Write-Output 'hello-world'"
    }
  }
}
```

### Configure with Bicep

```bicep
resource script 'Microsoft.Compute/virtualMachines/extensions@2015-06-15' = {
  name: 'installcustomscript'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    protectedSettings: {
        commandToExecute: 'Write-Output "hello-world"'
    }
  }
}
```

## LINKS

- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep)
- [Windows Custom Script Extensions](https://learn.microsoft.com/azure/virtual-machines/extensions/custom-script-windows)
- [Linux Custom Script Extensions](https://learn.microsoft.com/azure/virtual-machines/extensions/custom-script-linux)
