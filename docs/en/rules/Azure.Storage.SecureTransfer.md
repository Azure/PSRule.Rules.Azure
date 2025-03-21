---
reviewed: 2024-03-04
severity: Important
pillar: Security
category: SE:07 Encryption
resource: Storage Account
resourceType: Microsoft.Storage/storageAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.SecureTransfer/
ms-content-id: 539cb7b9-5510-4aa3-b422-41a049a10a88
---

# Enforce encrypted Storage connections

## SYNOPSIS

Storage accounts should only accept encrypted connections.

## DESCRIPTION

Azure Storage Accounts can be configured to allow unencrypted connections.
Unencrypted communication could allow disclosure of information to an un-trusted party.
Storage Accounts can be configured to require encrypted connections.

To do this set the _Secure transfer required_ option.
When _secure transfer required_ is enabled,
attempts to connect to storage using HTTP or unencrypted SMB connections are rejected.

Storage Accounts that are deployed with a newer API version will have this option enabled by default.
However, this does not prevent the option from being disabled.

## RECOMMENDATION

Storage accounts should only accept secure traffic.
Consider only accepting encrypted connections by setting the _Secure transfer required_ option.
Also consider using Azure Policy to audit or enforce this configuration.

## EXAMPLES

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- For API versions older then _2019-04-01_, set the `properties.supportsHttpsTrafficOnly` property to `true`.
- For API versions _2019-04-01_ and newer:
  - Omit the `properties.supportsHttpsTrafficOnly` property OR
  - Explicitly set the `properties.supportsHttpsTrafficOnly` property to `true`.

For example:

```json
{
  "type": "Microsoft.Storage/storageAccounts",
  "apiVersion": "2023-01-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard_GRS"
  },
  "kind": "StorageV2",
  "properties": {
    "allowBlobPublicAccess": false,
    "supportsHttpsTrafficOnly": true,
    "minimumTlsVersion": "TLS1_2",
    "accessTier": "Hot",
    "allowSharedKeyAccess": false,
    "networkAcls": {
      "defaultAction": "Deny"
    }
  }
}
```

### Configure with Bicep

To deploy Storage Accounts that pass this rule:

- For API versions older then _2019-04-01_, set the `properties.supportsHttpsTrafficOnly` property to `true`.
- For API versions _2019-04-01_ and newer:
  - Omit the `properties.supportsHttpsTrafficOnly` property OR
  - Explicitly set the `properties.supportsHttpsTrafficOnly` property to `true`.

For example:

```bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}
```

<!-- external:avm avm/res/storage/storage-account supportsHttpsTrafficOnly -->

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Secure transfer to storage accounts should be enabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Storage/Storage_AuditForHTTPSEnabled_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9`
- [Configure secure transfer of data on a storage account](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Storage/StorageAccountSecureTransfer_Modify.json)
  `/providers/Microsoft.Authorization/policyDefinitions/f81e3117-0093-4b17-8a60-82363134f0eb`

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [Require secure transfer in Azure Storage](https://learn.microsoft.com/azure/storage/common/storage-require-secure-transfer)
- [DP-3: Encrypt sensitive data in transit](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline#dp-3-encrypt-sensitive-data-in-transit)
- [Sample policy for ensuring https traffic](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#storage)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
