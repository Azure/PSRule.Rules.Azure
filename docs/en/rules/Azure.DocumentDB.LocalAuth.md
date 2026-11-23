---
reviewed: 2026-11-23
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Azure DocumentDB
resourceType: Microsoft.DocumentDB/mongoClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DocumentDB.LocalAuth/
---

# Disable native authentication on deployed Azure DocumentDB clusters

## SYNOPSIS

Deployed Azure DocumentDB clusters should disable native authentication.

## DESCRIPTION

Native authentication uses locally managed database credentials.
Microsoft Entra ID provides centralized identity management and avoids distributing database passwords to applications.
After provisioning and verifying Microsoft Entra ID access, remove `NativeAuth` from the cluster's allowed authentication modes.

Azure DocumentDB requires native authentication during initial cluster creation.
For this reason, this rule only evaluates exported Azure resource data with a `SubscriptionId` field.
It does not flag initial infrastructure deployments.

## RECOMMENDATION

Consider using only `MicrosoftEntraID` authentication after provisioning and testing access.

## EXAMPLES

### Configure with Azure CLI

After Microsoft Entra ID administrators and application identities can connect, update the existing cluster.

```azurecli
az resource update \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --resource-type Microsoft.DocumentDB/mongoClusters \
  --api-version 2026-06-01 \
  --set properties.authConfig.allowedModes='["MicrosoftEntraID"]'
```

### Evaluate the deployed configuration

Export the deployed cluster and evaluate the exported resources:

```powershell
Export-AzRuleData -ResourceGroupName 'rg-documentdb' -OutputPath '.\out\'
Invoke-PSRule -Module PSRule.Rules.Azure -InputPath '.\out\' -Name Azure.DocumentDB.LocalAuth
```

## NOTES

The allowed authentication modes must contain only `MicrosoftEntraID`.
Missing modes, empty modes, and configurations that still include `NativeAuth` fail.
Configure Entra ID access first to avoid locking users and applications out.
Use [Azure.DocumentDB.EntraID](Azure.DocumentDB.EntraID.md) for initial deployment checks.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication)
- [Configure Microsoft Entra ID authentication](https://learn.microsoft.com/azure/documentdb/how-to-connect-role-based-access-control)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters)
