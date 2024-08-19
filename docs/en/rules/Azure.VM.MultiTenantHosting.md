---
severity: Awareness
pillar: Cost Optimization
category: CO:08 Environment costs
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.MultiTenantHosting/
---

# Multitenant Hosting Rights

## SYNOPSIS

Deploy Windows 10 and 11 virtual machines in Azure using Multitenant Hosting Rights to leverage your existing Windows licenses.

## DESCRIPTION

Multitenant Hosting Rights allow you to bring your Windows 10 and 11 licenses to the cloud, enabling you to run virtual machines (VMs) on Azure without incurring additional licensing costs.
This benefit is applicable if you have Windows licenses with Software Assurance or qualifying subscription licenses, making it a cost-effective option for your Azure deployments.

By utilizing Multitenant Hosting Rights, you can reduce the total cost of ownership when running Windows VMs in Azure.
This is particularly advantageous for organizations that already have on-premises Windows licenses covered under Software Assurance or eligible subscription plans.

Please note that this benefit is available exclusively for Windows 10 Enterprise and Windows 11 Enterprise editions.

## RECOMMENDATION

Consider using Multitenant Hosting Rights to maximize your existing licensing investments when deploying Windows VMs in Azure.

### Configure with Azure template

To deploy virtual machines that pass this rule:

- Set the `properties.licenseType` property to `Windows_Client`.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachines",
  "apiVersion": "2024-07-01",
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
              "publisher": "MicrosoftWindowsDesktop",
              "offer": "windows-11",
              "sku": "win11-23h2-ent",
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
      "licenseType": "Windows_Client",
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

To deploy virtual machines that pass this rule:

- Set the `properties.licenseType` property to `Windows_Client`.

For example:

```bicep
resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
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
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-11'
        sku: 'win11-23h2-ent'
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
    licenseType: 'Windows_Client'
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

This rule may produce false negatives because it does not verify whether the installed Windows OS is an Enterprise edition.

### Rule configuration

<!-- module:config rule AZURE_VM_MULTI_TENANT_HOSTING_RIGHTS -->

By default, this rule is ignored.
For this rule to apply, set the `AZURE_VM_MULTI_TENANT_HOSTING_RIGHTS` configuration value to `true`.

For example:

```yaml
configuration:
  AZURE_VM_MULTI_TENANT_HOSTING_RIGHTS: true
```

## LINKS

- [CO:08 Environment costs](https://learn.microsoft.com/azure/well-architected/cost-optimization/optimize-environment-costs)
- [Multitenant Hosting Rights](https://learn.microsoft.com/azure/virtual-machines/windows/windows-desktop-multitenant-hosting-deployment)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets/virtualmachines)
