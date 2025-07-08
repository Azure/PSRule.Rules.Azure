---
reviewed: 2024-12-16
severity: High
pillar: Security
category: DP:02 Data Protection
resource: Container Registry
resourceType: Microsoft.ContainerRegistry/registries
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.ExportPolicy/
ms-content-id: bbf194a7-6ca3-4b1d-9170-6217eb26620e
---

# Container Registry export policy should be disabled

## SYNOPSIS

Disable export of artifacts from Azure container registry to ensure data is accessed solely via the data plane.

## DESCRIPTION

Azure Container Registry (ACR) export policy allows copying container images and artifacts to other registries or locations. 
When the export policy is enabled, data can be moved out of the registry via 'acr import' or 'acr transfer' commands.

To improve security and prevent data exfiltration, the export policy should be disabled.
This ensures that data in the registry is accessed solely through the data plane using standard Docker commands like 'docker pull'.

Disabling export policy requires that public network access is also disabled.
This provides additional protection by ensuring the registry is only accessible from private networks.

## RECOMMENDATION

Consider disabling the export policy and public network access for container registries containing sensitive data.

## EXAMPLES

### Configure with Azure template

To deploy registries that pass this rule:

- Set `properties.policies.exportPolicy.status` to `disabled`.
- Set `properties.publicNetworkAccess` to `Disabled`.

For example:

```json
{
  "type": "Microsoft.ContainerRegistry/registries",
  "apiVersion": "2023-07-01",
  "name": "[parameters('registryName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Premium"
  },
  "properties": {
    "adminUserEnabled": false,
    "publicNetworkAccess": "Disabled",
    "policies": {
      "exportPolicy": {
        "status": "disabled"
      }
    }
  }
}
```

### Configure with Bicep

To deploy registries that pass this rule:

- Set `properties.policies.exportPolicy.status` to `disabled`.
- Set `properties.publicNetworkAccess` to `Disabled`.

For example:

```bicep
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: registryName
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Disabled'
    policies: {
      exportPolicy: {
        status: 'disabled'
      }
    }
  }
}
```

### Configure with Azure CLI

```bash
az acr update --name MyRegistry --public-network-enabled false
az acr config export-policy update --registry MyRegistry --status disabled
```

### Configure with Azure PowerShell

```powershell
Update-AzContainerRegistry -Name MyRegistry -ResourceGroupName MyResourceGroup -PublicNetworkAccess Disabled
# Export policy configuration requires REST API calls as PowerShell cmdlets don't support it directly
```

## NOTES

An Azure container registry with export policy disabled:

- Prevents copying registry data using ACR import/export commands.
- Requires public network access to be disabled.
- Allows standard Docker operations (pull, push) through private endpoints.
- Is available for Premium tier registries only.

## LINKS

- [Data loss prevention for Azure Container Registry](https://learn.microsoft.com/en-gb/azure/container-registry/data-loss-prevention)
- [Azure Security Benchmark - Monitor anomalies and threats targeting sensitive data](https://learn.microsoft.com/en-gb/security/benchmark/azure/baselines/container-registry-security-baseline?toc=%2Fazure%2Fcontainer-registry%2FTOC.json#dp-2-monitor-anomalies-and-threats-targeting-sensitive-data)
- [Azure Policy - Container registries should have exports disabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Container%20Registry/ACR_ExportPolicy_AuditDeny.json)
- [Container Registry REST API](https://docs.microsoft.com/en-us/rest/api/containerregistry/)