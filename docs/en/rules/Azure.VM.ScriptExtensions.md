---
reviewed: 2022-11-16
severity: Important
pillar: Security
category: SE:02 Secured development lifecycle
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

Consider specifying secure values within `protectedSettings` to avoid exposing secrets during extension deployments.

## EXAMPLES

### Configure with Azure template

To deploy VM extensions that pass this rule:

- Set any secure values within `properties.protectedSettings`.

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

To deploy VM extensions that pass this rule:

- Set any secure values within `properties.protectedSettings`.

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

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Windows Custom Script Extensions](https://learn.microsoft.com/azure/virtual-machines/extensions/custom-script-windows)
- [Linux Custom Script Extensions](https://learn.microsoft.com/azure/virtual-machines/extensions/custom-script-linux)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines/extensions)
