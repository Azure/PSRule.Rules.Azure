---
severity: Important
pillar: Operational Excellence
category: Infrastructure provisioning
resource: App Service Environment
resourceType: Microsoft.Web/hostingEnvironments
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ASE.MigrateV3/
---

# Migrate to App Service Environment v3

## SYNOPSIS

Use ASEv3 as replacement for the classic app service environment versions ASEv1 and ASEv2.

## DESCRIPTION

The classic App Service Environment version 1 (ASEv1) and version 2 (ASEv2) will be retired on August 31, 2024.
To avoid service disruption, migrate to App Service Environment version 3 (ASEv3).
App Service Environment v3 has advantages and feature differences that provide enhanced support for your workloads and can reduce overall costs.

App Service Environment v3 differs from earlier versions in the following ways:

- There are no networking dependencies on the customer's virtual network.
  You can secure all inbound and outbound traffic and route outbound traffic as you want.
- You can deploy an App Service Environment v3 that's enabled for zone redundancy.
  You set zone redundancy only during creation and only in regions where all App Service Environment v3 dependencies are zone redundant.
  In this case, each App Service Plan on the App Service Environment will need to have a minimum of three instances so that they can be spread across zones.
  For more information, see Migrate App Service Environment to availability zone support.
- You can deploy an App Service Environment v3 on a dedicated host group.
  Host group deployments aren't zone redundant.
- Scaling is much faster than with an App Service Environment v2.
  Although scaling still isn't immediate, as in the multi-tenant service, it's a lot faster.
- Front-end scaling adjustments are no longer required.
  App Service Environment v3 front ends automatically scale to meet your needs and are deployed on better hosts.
- Scaling no longer blocks other scale operations within the App Service Environment v3.
  Only one scale operation can be in effect for a combination of OS and size.
  For example, while your Windows small App Service plan is scaling, you could kick off a scale operation to run at the same time on a Windows medium or anything else other than Windows small.
- You can reach apps in an internal-VIP App Service Environment v3 across global peering.
  Such access wasn't possible in earlier versions.

A few features that were available in earlier versions of App Service Environment aren't available in App Service Environment v3.
For example, you can no longer do the following:

- Monitor your traffic with Network Watcher or network security group (NSG) flow logs.
- Perform a backup and restore operation on a storage account behind a firewall.

## RECOMMENDATION

Classic App Service Environments should migrate to App Service Environment v3.

## EXAMPLES

### Configure with Azure template

To deploy app service environments pass this rule:

- Set `kind` to `'ASEV3'`.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.11.1.770",
      "templateHash": "13381170219553357893"
    }
  },
  "parameters": {
    "aseName": {
      "type": "string",
      "defaultValue": "001-ase",
      "metadata": {
        "description": "Name of the App Service Environment"
      }
    },
    "virtualNetworkName": {
      "type": "string",
      "defaultValue": "ase-001-vnet",
      "metadata": {
        "description": "The name of the vnet"
      }
    },
    "vnetResourceGroupName": {
      "type": "string",
      "defaultValue": "ase-001-rg",
      "metadata": {
        "description": "The resource group name that contains the vnet"
      }
    },
    "subnetName": {
      "type": "string",
      "defaultValue": "ase-001-sn",
      "metadata": {
        "description": "Subnet name that will contain the App Service Environment"
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for the resources"
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Web/hostingEnvironments",
      "apiVersion": "2022-03-01",
      "name": "[parameters('aseName')]",
      "location": "[parameters('location')]",
      "kind": "ASEV3",
      "tags": {
        "displayName": "App Service Environment",
        "usage": "Hosting awesome applications",
        "owner": "Platform"
      },
      "properties": {
        "virtualNetwork": {
          "id": "[extensionResourceId(format('/subscriptions/{0}/resourceGroups/{1}', subscription().subscriptionId, parameters('vnetResourceGroupName')), 'Microsoft.Network/virtualNetworks/subnets', parameters('virtualNetworkName'), parameters('subnetName'))]"
        }
      }
    }
  ]
}
```

### Configure with Bicep

To deploy app service environments pass this rule:

- Set `kind` to `'ASEV3'`.

For example:

```bicep
@description('Name of the App Service Environment')
param aseName string = '001-ase'

@description('The name of the vnet')
param virtualNetworkName string = 'ase-001-vnet'

@description('The resource group name that contains the vnet')
param vnetResourceGroupName string = 'ase-001-rg'

@description('Subnet name that will contain the App Service Environment')
param subnetName string = 'ase-001-sn'

@description('Location for the resources')
param location string = resourceGroup().location

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  scope: resourceGroup(vnetResourceGroupName)
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  parent: virtualNetwork
  name: subnetName
}

resource hostingEnvironment 'Microsoft.Web/hostingEnvironments@2022-03-01' = {
  name: aseName
  location: location
  kind: 'ASEV3'
  tags: {
    displayName: 'App Service Environment'
    usage: 'Hosting awesome applications'
    owner: 'Platform'
  }
  properties: {
    virtualNetwork: {
      id: subnet.id
    }
  }
}
```

## LINKS

- [Infrastructure provisioning](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [App Service Environment version 1 and version 2 will be retired on 31 August 2024](https://azure.microsoft.com/updates/app-service-environment-v1-and-v2-retirement-announcement)
- [Migrate to App Service Environment v3](https://learn.microsoft.com/azure/app-service/environment/migration-alternatives)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/hostingenvironments)
