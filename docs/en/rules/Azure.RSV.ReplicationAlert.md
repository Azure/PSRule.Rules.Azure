---
severity: Important
pillar: Reliability
category: Design
resource: Azure Recovery Services Vault (RSV)
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.RSV.ReplicationAlert/
---

# Use geo-replicated storage

## SYNOPSIS

Recovery Services Vaults (RSV) without replication alerts configured may be at risk.

## DESCRIPTION

Recovery Services Vaults (RSV) can be used to replicate virtual machines between Azure Regions.
Alerts can be configured to send notifications when replication issues occur.

The replication alerts can be configured for:

- The resources owners (Based on RBAC permissions).
- A list of email addresses.

## RECOMMENDATION

Configure replication alerts for Recovery Service Vaults that are performing replication tasks.

## EXAMPLES

### Configure with Azure template

By default a Recovery Services vaults does not have replication alerts setup. To define a replication
alert via ARM templates either configure the `sendToOwners` or `CustomerEmailAddress` properties:

- Set `properties.sendToOwners` to `Send`.
- Set `properties.customEmailAddresses` to `[ "example@email.com" ]`

For example:

```json
{
  "type": "Microsoft.RecoveryServices/vaults/replicationAlertSettings",
  "apiVersion": "2021-08-01",
  "name": "replicationAlert",
  "properties": {
    "sendToOwners": "Send",
    "customEmailAddresses": [
      "example@email.com"
    ]
  }
}
```

### Configure with Bicep
By default a Recovery Services vaults does not have replication alerts setup. To define a replication
alert via a Bicep either configure the `sendToOwners` or `CustomerEmailAddress` properties:

- Set `properties.sendToOwners` to `Send`.
- Set `properties.customEmailAddresses` to `[ "example@email.com" ]`

For example:

```bicep
resource testRecoveryServices 'Microsoft.RecoveryServices/vaults/replicationAlertSettings@2021-08-01' = {
  name: 'replicationAlert'
  parent: resourceSymbolicName
  properties: {
    sendToOwners: 'Sender'
    customEmailAddresses: [
      'example@email.com'
    ]
    locale: 'en-US'
  }
}
```
## NOTES

with the locale property you can define the locale for the email notification.

## LINKS

- [Recovery Services Vault - Overview](https://docs.microsoft.com/azure/backup/backup-azure-recovery-services-vault-overview#storage-settings-in-the-recovery-services-vault)
- [Recovery Services Vault - Replication Alerts](https://docs.microsoft.com/azure/backup/backup-azure-manage-windows-server#configuring-notifications-for-alerts)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.recoveryservices/vaults/replicationalertsettings?tabs=bicep)
- [Well Architected Framework - Reliability](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-resiliency)
