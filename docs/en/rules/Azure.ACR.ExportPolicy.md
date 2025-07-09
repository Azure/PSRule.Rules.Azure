---
reviewed: 2025-07-09
severity: Important
pillar: Security
category: SE:08 Hardening resources
resource: Container Registry
resourceType: Microsoft.ContainerRegistry/registries
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.ExportPolicy/
---

# Container Registry export policy should be disabled

## SYNOPSIS

Disable export of artifacts from Azure container registry to ensure data is accessed solely via the data plane.

## DESCRIPTION

Azure Container Registry (ACR) export policy allows copying container images and artifacts to other registries or locations. 
When the export policy is enabled, data can be moved out of the registry via 'acr import' or 'acr transfer' commands.

To improve security and prevent data exfiltration, the export policy should be disabled.
This ensures that data in the registry is accessed solely through the data plane using standard Docker commands like 'docker pull'.

## RECOMMENDATION

Consider disabling the export policy for container registries containing sensitive data.

## EXAMPLES

### Configure with Bicep

To deploy registries that pass this rule:

- Set `properties.policies.exportPolicy.status` to `disabled`.

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
    policies: {
      exportPolicy: {
        status: 'disabled'
      }
    }
  }
}
```

### Configure with Azure template

To deploy registries that pass this rule:

- Set `properties.policies.exportPolicy.status` to `disabled`.

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
    "policies": {
      "exportPolicy": {
        "status": "disabled"
      }
    }
  }
}
```

### Configure with Azure CLI

```bash
az acr config export-policy update --registry <name> --status disabled
```

### Configure with Azure PowerShell

```powershell
# Configure export policy using Azure CLI (PowerShell does not have direct support)
az acr config export-policy update --registry <name> --status disabled
```

## NOTES

An Azure container registry with export policy disabled:

- Prevents copying registry data using ACR import/export commands.
- Allows standard Docker operations (pull, push) through private endpoints.
- Is available for Premium tier registries only.

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/en-us/azure/well-architected/security/harden-resources)
- [Data loss prevention for Azure Container Registry](https://learn.microsoft.com/azure/container-registry/data-loss-prevention)
- [Azure Security Benchmark - Monitor anomalies and threats targeting sensitive data](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#dp-2-monitor-anomalies-and-threats-targeting-sensitive-data)
- [Azure Policy - Container registries should have exports disabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Container%20Registry/ACR_ExportPolicy_AuditDeny.json)
- [Azure deployment reference - Container Registry](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)