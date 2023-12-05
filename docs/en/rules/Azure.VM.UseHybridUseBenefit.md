---
severity: Awareness
pillar: Cost Optimization
category: Pricing and billing model
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.UseHybridUseBenefit/
---

# Use Azure Hybrid Benefit

## SYNOPSIS

Use Azure Hybrid Benefit for applicable virtual machine (VM) workloads.

## DESCRIPTION

Azure Hybrid Benefit is a licensing benefit that helps you to reduce costs of running virtual machine (VM) workloads.

## RECOMMENDATION

Consider using Azure Hybrid Benefit for eligible workloads.

## EXAMPLES

### Configure with Azure template

To deploy VMs that pass this rule:

- Set the `properties.licenseType` property to one of the following:
  - `Windows_Server`
  - `Windows_Client`

For example:

```json
{
    "type": "Microsoft.Compute/virtualMachines",
    "apiVersion": "2021-07-01",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
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
                "createOption": "FromImage"
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

To deploy VMs that pass this rule:

- Set the `properties.licenseType` property to one of the following:
  - `Windows_Server`
  - `Windows_Client`

For example:

```bicep
resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: name
  location: location
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

### Configure with Azure CLI

```bash
az vm update -n '<name>' -g '<resource_group>' --set licenseType=Windows_Server
```

## LINKS

- [Design review checklist for Cost Optimization](https://learn.microsoft.com/azure/well-architected/cost-optimization/checklist)
- [Azure Hybrid Benefit FAQ](https://azure.microsoft.com/pricing/hybrid-benefit/faq/)
- [Explore Azure Hybrid Benefit for Windows VMs](https://learn.microsoft.com/azure/virtual-machines/windows/hybrid-use-benefit-licensing)
