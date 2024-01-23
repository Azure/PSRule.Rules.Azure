---
reviewed: 2024-01-24
severity: Awareness
pillar: Cost Optimization
category: CO:06 Usage and billing increments
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.DiskSizeAlignment/
---

# Allocate VM disks aligned to billing model

## SYNOPSIS

Align to the Managed Disk billing increments to improve cost efficiency.

## DESCRIPTION

Azure managed disks are billed based on predefined size increments.
The billing increments are based on the disk storage type.
These include:

- `Premium SSD` - 4/ 8/ 16/ 32/ 64/ 128/ 256/ 512/ 1024/ 2048/ 4096/ 8192/ 16384/ 32768 GiB.
- `Standard SSD` - 4/ 8/ 16/ 32/ 64/ 128/ 256/ 512/ 1024/ 2048/ 4096/ 8192/ 16384/ 32768 GiB.
- `Standard HDD` - 32/ 64/ 128/ 256/ 512/ 1024/ 2048/ 4096/ 8192/ 16384/ 32768 GiB.
- `Ultra SSD` - 4/ 8/ 16/ 32/ 64/ 128/ 256/ 512 GiB, then 1 TiB increments to 64 TiB.

If you provision a disk that is not aligned to the billing model, you will be billed for the next increment.
For example, if a disk is provisioned at 33 GiB, the disk is billed as 64 GiB.

## RECOMMENDATION

Consider aligning provisioned disk sizes to the billing increments for Managed Disks to improve cost efficiency.

## EXAMPLES

### Configure with Azure template

To deploy managed disks that pass this rule:

- Set the `properties.diskSizeGB` property to a value that aligns to the billing model of the disk storage type.
  E.g. `32`.

For example:

```json
{
  "type": "Microsoft.Compute/disks",
  "apiVersion": "2023-04-02",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Premium_ZRS"
  },
  "properties": {
    "creationData": {
      "createOption": "Empty"
    },
    "diskSizeGB": 32
  }
}
```

### Configure with Bicep

To deploy managed disks that pass this rule:

- Set the `properties.diskSizeGB` property to a value that aligns to the billing model of the disk storage type.
  E.g. `32`.

For example:

```bicep
resource dataDisk 'Microsoft.Compute/disks@2023-04-02' = {
  name: name
  location: location
  sku: {
    name: 'Premium_ZRS'
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 32
  }
}
```

## NOTES

This rule has the following limitations:

- This rule applies to managed disks using the following storage type: Ultra SSD, Premium SSD, and Standard SSD/ HDD disks.
  - Premium v2 disks are billed per provisioned disk capacity based on 1 GiB increments.
  - Unmanaged disks are ignored.
- The rule does not fail if the disk size is within 5 GiB on the next size.
  For example: A 30 GiB disk is not aligned to the billed size of 32 GiB, but is within 5 GiB.
- Disks with a marketplace purchase plan are ignored.
  These disks are predefined by the publisher are often unable to be reconfigured.

## LINKS

- [CO:06 Usage and billing increments](https://learn.microsoft.com/azure/well-architected/cost-optimization/align-usage-to-billing-increments)
- [Managed Disks pricing](https://azure.microsoft.com/pricing/details/managed-disks/)
- [Azure managed disk types](https://learn.microsoft.com/azure/virtual-machines/disks-types)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/disks)
