---
reviewed: 2024-06-17
severity: Important
pillar: Security
category: SE:06 Network controls
resource: Key Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.Firewall/
---

# Configure Azure Key Vault firewall

## SYNOPSIS

Key Vault should only accept explicitly allowed traffic.

## DESCRIPTION

By default, Key Vault accept connections from clients on any network.
To limit access to selected networks, you must first change the default action.

After changing the default action from `Allow` to `Deny`, configure one or more rules to allow traffic.
Traffic can be allowed from:

- Azure services on the trusted service list.
- IP address or CIDR range.
- Private endpoint connections.
- Azure virtual network subnets with a Service Endpoint.

If any of the following options are enabled you must also enable _Allow trusted Microsoft services to bypass this firewall_:

- `enabledForDeployment` - _Azure Virtual Machines for deployment_.
- `enabledForDiskEncryption` - _Azure Disk Encryption for volume encryption_.
- `enabledForTemplateDeployment` - _Azure Resource Manager for template deployment_.

## RECOMMENDATION

Consider configuring Key Vault firewall to restrict network access to permitted clients only.
Also consider enforcing this setting using Azure Policy.

## EXAMPLES

### Configure with Azure template

To deploy Key Vaults that pass this rule:

- Set the `properties.networkAcls.defaultAction` property to `Deny`.

For example:

```json
{
  "type": "Microsoft.KeyVault/vaults",
  "apiVersion": "2023-02-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "sku": {
      "family": "A",
      "name": "premium"
    },
    "tenantId": "[tenant().tenantId]",
    "softDeleteRetentionInDays": 90,
    "enableSoftDelete": true,
    "enablePurgeProtection": true,
    "enableRbacAuthorization": true,
    "networkAcls": {
      "defaultAction": "Deny",
      "bypass": "AzureServices"
    }
  }
}
```

### Configure with Bicep

To deploy Key Vaults that pass this rule:

- Set the `properties.networkAcls.defaultAction` property to `Deny`.

For example:

```bicep
resource vault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: tenant().tenantId
    softDeleteRetentionInDays: 90
    enableSoftDelete: true
    enablePurgeProtection: true
    enableRbacAuthorization: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}
```

<!-- external:avm avm/res/key-vault/vault networkAcls -->

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Azure Key Vault should have firewall enabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Key%20Vault/FirewallEnabled_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/55615ac9-af46-4a59-874e-391cc3dfb490`.
- [Configure key vaults to enable firewall](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Key%20Vault/FirewallEnabled_Modify.json)
  `/providers/Microsoft.Authorization/policyDefinitions/ac673a9a-f77d-4846-b2d8-a57f8e1c01dc`.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [NS-2: Secure cloud services with network controls](https://learn.microsoft.com/security/benchmark/azure/baselines/key-vault-security-baseline#disable-public-network-access)
- [Configure Azure Key Vault firewalls and virtual networks](https://learn.microsoft.com/azure/key-vault/general/network-security)
- [Trusted services](https://learn.microsoft.com/azure/key-vault/general/overview-vnet-service-endpoints#trusted-services)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults)
