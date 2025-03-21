---
severity: Important
pillar: Reliability
category: Design
resource: Recovery Services Vault
resourceType: Microsoft.RecoveryServices/vaults,Microsoft.RecoveryServices/vaults/backupconfig
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.RSV.StorageType/
---

# Use geo-replicated storage

## SYNOPSIS

Recovery Services Vaults (RSV) not using geo-replicated storage (GRS) may be at risk.

## DESCRIPTION

Recovery Services Vaults can be configured with several different durability options.
Azure provides a number of geo-replicated options for storage including;
Geo-redundant storage and read access geo-zone-redundant storage.
The default storage type used will be Geo-redundant
Geo-zone-redundant storage is only available in supported regions.

The following geo-replicated options are available for recovery services vaults:

- `GeoRedundant`
- `ReadAccessGeoZoneRedundant`

## RECOMMENDATION

Consider using GeoRedundant for recovery services vaults that contain data.

## EXAMPLES

### Configure with Azure template

The default storage type used by Recovery Services vaults is Geo-redundant.
However if you're defining the backup config in an ARM template:

- Set `properties.storageType` to either `GeoRedundant` or `ReadAccessGeoZoneRedundant`.
For example:

```json
{
  "type": "Microsoft.RecoveryServices/vaults/backupconfig",
  "apiVersion": "2021-10-01",
  "name": "vaultconfig-a",
  "location": "australiaeast",
  "tags": {},
  "properties": {
    "storageType": "GeoRedundant"
  }
}
```

### Configure with Bicep

The default storage type used by Recovery Services vaults is Geo-redundant.
However if you're defining the backup config via Bicep:

- Set `properties.storageType` to either `GeoRedundant` or `ReadAccessGeoZoneRedundant`.

For example:

```bicep
resource testRecoveryServices 'Microsoft.RecoveryServices/vaults/backupconfig@2021-10-01' = {
  name: 'vaultconfig'
  location: 'string'
  parent: resourceSymbolicName
  properties: {
    storageType: 'GeoRedundant'
  }
}
```

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Recovery Services Vault - Overview](https://learn.microsoft.com/azure/backup/backup-azure-recovery-services-vault-overview#storage-settings-in-the-recovery-services-vault)
- [Recovery Services Vault - Storage Settings](https://learn.microsoft.com/azure/backup/backup-create-recovery-services-vault#set-storage-redundancy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.recoveryservices/vaults/backupconfig)
