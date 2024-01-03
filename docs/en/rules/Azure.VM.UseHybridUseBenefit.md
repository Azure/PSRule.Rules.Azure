---
reviewed: 2024-01-03
severity: Awareness
pillar: Cost Optimization
category: CO:05 Rate optimization
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.UseHybridUseBenefit/
---

# Use Azure Hybrid Benefit

## SYNOPSIS

Use Azure Hybrid Benefit for applicable virtual machine (VM) workloads.

## DESCRIPTION

The running cost of Virtual machine (VM) workloads in Azure is composed of several components, including:

- Compute usage for the VM size and image billed per second of run time, which may include:
  - Base compute rate for the VM size.
  - Software included on the VM image billed per second of run time, such as Windows Server or SQL Server.
- Storage usage for the VM disks.
- Network usage for data transfer in and out of the VM.
- Usage of other supporting Azure resources, such as load balancers, public IP addresses, or log ingestion.
- Licensing costs for other software installed on the VM.

Azure Hybrid Benefit is a licensing benefit that helps you to reduce your overall cost of ownership.
With Azure Hybrid Benefit you to use your existing on-premises licenses to pay a reduced rate on Azure.

When Azure Hybrid Benefit enabled on supported VM images:

- The billing rate for the VM is adjusted to the base compute rate.
- You must separately have eligible licenses, such as Windows Server or SQL Server because Azure does not include these anymore.

For additional information on Azure Hybrid Benefit, see the [Azure Hybrid Benefit FAQ][1].

  [1]: https://azure.microsoft.com/pricing/hybrid-benefit/#faq

## RECOMMENDATION

Consider using Azure Hybrid Benefit for eligible virtual machine (VM) workloads.

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
  "apiVersion": "2023-09-01",
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
          "id": "[resourceId('Microsoft.Network/networkInterfaces', parameters('nicName'))]"
        }
      ]
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Network/networkInterfaces', parameters('nicName'))]"
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
resource vm_with_benefit 'Microsoft.Compute/virtualMachines@2023-09-01' = {
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

### Configure with Azure CLI

```bash
az vm update -n '<name>' -g '<resource_group>' --set licenseType=Windows_Server
```

### NOTES

This rule is not processed by default.
To enable this rule, set the `AZURE_VM_USE_AZURE_HYBRID_BENEFIT` configuration value to `true`.

For example:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_VM_USE_AZURE_HYBRID_BENEFIT: true
```

The following limitations currently apply:

- This rule only applies to Azure Hybrid Benefit for Windows VMs.
  Linux VM images are ignored.

## LINKS

- [CO:05 Rate optimization](https://learn.microsoft.com/azure/well-architected/cost-optimization/get-best-rates)
- [Azure Hybrid Benefit FAQ](https://azure.microsoft.com/pricing/hybrid-benefit/#faq)
- [Explore Azure Hybrid Benefit for Windows VMs](https://learn.microsoft.com/azure/virtual-machines/windows/hybrid-use-benefit-licensing)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
