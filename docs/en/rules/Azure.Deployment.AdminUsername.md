---
severity: Awareness
pillar: Security
category: Infrastructure provisioning
resource: Deployment
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Deployment.AdminUsername/
---

# Administrator Username Types

## SYNOPSIS

Use secure parameters for sensitive resource properties.

## DESCRIPTION

Resource properties can be configured using a hardcoded value or Azure Bicep/ template expressions.
When specifing sensitive values use _secure_ parameters such as `secureString` or `secureObject`.

Sensitive values that use deterministic expressions such as hardcodes string literals or variables are not secure.

## RECOMMENDATION

Sensitive properties should be passed as parameters.
Avoid using deterministic values for sensitive properties.

## EXAMPLES

### Configure with Azure template

To deploy resources that pass this rule:

- Use parameters to specify sensitive properties.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachines",
  "apiVersion": "2022-03-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "zones": [
    "1"
  ],
  "properties": {
    "hardwareProfile": {
      "vmSize": "Standard_D2s_v3"
    },
    "osProfile": {
      "computerName": "[parameters('name')]",
      "adminUsername": "[parameters('adminUsername')]",
      "adminPassword": "[parameters('adminPassword')]"
    },
    "storageProfile": {
      "imageReference": {
        "publisher": "MicrosoftWindowsServer",
        "offer": "WindowsServer",
        "sku": "[parameters('sku')]",
        "version": "latest"
      },
      "osDisk": {
        "name": "[format('{0}-disk0', parameters('name'))]",
        "caching": "ReadWrite",
        "createOption": "FromImage",
        "managedDisk": {
          "storageAccountType": "Premium_LRS"
        }
      }
    },
    "licenseType": "Windows_Server",
    "networkProfile": {
      "networkInterfaces": [
        {
          "id": "[resourceId('Microsoft.Network/networkInterfaces', format('{0}-nic0', parameters('name')))]"
        }
      ]
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Network/networkInterfaces', format('{0}-nic0', parameters('name')))]"
  ]
}
```

### Configure with Bicep

To deploy resources that pass this rule:

- steps

For example:

```bicep
@secure()
@description('The name of the local administrator account.')
param adminUsername string

@secure()
@description('A password for the local administrator account.')
param adminPassword string

resource vm1 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: name
  location: location
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: sku
        version: 'latest'
      }
      osDisk: {
        name: '${name}-disk0'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    licenseType: 'Windows_Server'
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
```

## NOTES

Configure `AZURE_DEPLOYMENT_SENSITIVE_PROPERTY_NAMES` to specify sensitive property names.
By default the following values are used:

- `adminUsername`
- `administratorLogin`
- `administratorLoginPassword`

## LINKS

- [Infrastructure provisioning considerations in Azure](https://learn.microsoft.com/azure/architecture/framework/security/deploy-infrastructure)
- [Use Azure Key Vault to pass secure parameter value during Bicep deployment](https://learn.microsoft.com/azure/azure-resource-manager/bicep/key-vault-parameter)
- [Integrate Azure Key Vault in your ARM template deployment](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-tutorial-use-key-vault#edit-the-parameters-file)
