---
reviewed: 2025-09-21
severity: Important
pillar: Security
category: SE:08 Hardening resources
resource: Container Registry
resourceType: Microsoft.ContainerRegistry/registries
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.ExportPolicy/
---

# Container Registry export policy should be disabled

## SYNOPSIS

Export policy on Azure container registry may allow artifact exfiltration.

## DESCRIPTION

Azure Container Registry (ACR) export policy allows copying container images and artifacts to other registries or locations.
When the export policy is enabled, data can be moved out of the registry via `acr import` or `acr transfer` commands.

To improve security and prevent exfiltration, the export policy should be disabled from an _already network restricted registry_.
An already network restricted registry is one that has `publicNetworkAccess` set to `Disabled` and is accessible only
through private endpoints.

Disabling export of artifacts does not prevent authorized access to the registry within the virtual network to
pull artifacts or perform other data-plane operations.

To audit registry use, configure diagnostic settings to monitor registry operations.

## RECOMMENDATION

Consider disabling public network access and the export policy status for private container registries.

## EXAMPLES

### Configure with Bicep

To deploy registries that pass this rule:

- Set `properties.policies.exportPolicy.status` to `disabled`.
- Set `properties.publicNetworkAccess` to `Disabled` to restrict access to private endpoints only.

For example:

```bicep
resource registry 'Microsoft.ContainerRegistry/registries@2025-05-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Enabled'
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      retentionPolicy: {
        days: 30
        status: 'enabled'
      }
      softDeletePolicy: {
        retentionDays: 90
        status: 'enabled'
      }
      exportPolicy: {
        status: 'disabled'
      }
    }
  }
}
```

<!-- external:avm avm/res/container-registry/registry exportPolicyStatus -->

### Configure with Azure template

To deploy registries that pass this rule:

- Set `properties.policies.exportPolicy.status` to `disabled`.
- Set `properties.publicNetworkAccess` to `Disabled` to restrict access to private endpoints only.

For example:

```json
{
  "type": "Microsoft.ContainerRegistry/registries",
  "apiVersion": "2025-05-01-preview",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Premium"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "adminUserEnabled": false,
    "anonymousPullEnabled": false,
    "publicNetworkAccess": "Disabled",
    "zoneRedundancy": "Enabled",
    "policies": {
      "quarantinePolicy": {
        "status": "enabled"
      },
      "retentionPolicy": {
        "days": 30,
        "status": "enabled"
      },
      "softDeletePolicy": {
        "retentionDays": 90,
        "status": "enabled"
      },
      "exportPolicy": {
        "status": "disabled"
      }
    }
  }
}
```

### Configure with Azure CLI

```bash
az resource update -n '<name>' -g '<resource_group>' --resource-type 'Microsoft.ContainerRegistry/registries' --api-version '2021-06-01-preview' --set 'properties.policies.exportPolicy.status=disabled' --set 'properties.publicNetworkAccess=disabled'
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Container registries should have exports disabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Container%20Registry/ACR_ExportPolicy_AuditDeny.json)
  `/providers/Microsoft.Authorization/policyDefinitions/524b0254-c285-4903-bee6-bb8126cde579`.

## NOTES

An Azure container registry with export policy disabled:

- Prevents copying registry data using ACR import/ export jobs.
- Allows standard operations through private endpoints.
- Is available for Premium tier registries only.

This rule may produce false positives if the registry is intended to serve artifacts to external clients,
such as in the case of public registries.

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [Data loss prevention for Azure Container Registry](https://learn.microsoft.com/azure/container-registry/data-loss-prevention)
- [Azure Security Benchmark - Monitor anomalies and threats targeting sensitive data](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#dp-2-monitor-anomalies-and-threats-targeting-sensitive-data)
- [Azure Policy - Container registries should have exports disabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Container%20Registry/ACR_ExportPolicy_AuditDeny.json)
- [Azure deployment reference - Container Registry](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)
