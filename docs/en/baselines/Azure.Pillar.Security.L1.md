---
taxonomy: Azure.WAF
pillar: Security
maturity: L1
export: true
moduleVersion: v1.36.0
experimental: true
generated: true
---

# Azure.Pillar.Security.L1

Microsoft Azure Well-Architected Framework - Security pillar Level 1 maturity baseline.

## Rules

The following rules are included within the `Azure.Pillar.Security.L1` baseline.

This baseline includes a total of 33 rules.



[:material-download: Download CSV](Azure.Pillar.Security.L1.csv){ .md-button }



Name | Synopsis | Severity | Maturity
---- | -------- | -------- | --------
[Azure.ACR.AdminUser](../rules/Azure.ACR.AdminUser.md) | The local admin account allows depersonalized access to a container registry using a shared secret. | Critical | L1
[Azure.ADX.DiskEncryption](../rules/Azure.ADX.DiskEncryption.md) | Use disk encryption for Azure Data Explorer (ADX) clusters. | Important | L1
[Azure.AI.DisableLocalAuth](../rules/Azure.AI.DisableLocalAuth.md) | Access keys allow depersonalized access to Azure AI using a shared secret. | Important | L1
[Azure.AI.ManagedIdentity](../rules/Azure.AI.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important | L1
[Azure.AKS.AuditLogs](../rules/Azure.AKS.AuditLogs.md) | AKS clusters should collect security-based audit logs to assess and monitor the compliance status of workloads. | Important | L1
[Azure.AKS.LocalAccounts](../rules/Azure.AKS.LocalAccounts.md) | Enforce named user accounts with RBAC assigned permissions. | Important | L1
[Azure.AKS.ManagedAAD](../rules/Azure.AKS.ManagedAAD.md) | Use AKS-managed Azure AD to simplify authorization and improve security. | Important | L1
[Azure.AKS.ManagedIdentity](../rules/Azure.AKS.ManagedIdentity.md) | Configure AKS clusters to use managed identities for managing cluster infrastructure. | Important | L1
[Azure.APIM.Ciphers](../rules/Azure.APIM.Ciphers.md) | API Management should not accept weak or deprecated ciphers for client or backend communication. | Critical | L1
[Azure.APIM.HTTPBackend](../rules/Azure.APIM.HTTPBackend.md) | Unencrypted communication could allow disclosure of information to an untrusted party. | Critical | L1
[Azure.APIM.HTTPEndpoint](../rules/Azure.APIM.HTTPEndpoint.md) | Unencrypted communication could allow disclosure of information to an untrusted party. | Important | L1
[Azure.APIM.ManagedIdentity](../rules/Azure.APIM.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important | L1
[Azure.APIM.Protocols](../rules/Azure.APIM.Protocols.md) | API Management should only accept a minimum of TLS 1.2 for client and backend communication. | Critical | L1
[Azure.AppConfig.DisableLocalAuth](../rules/Azure.AppConfig.DisableLocalAuth.md) | Access keys allow depersonalized access to App Configuration using a shared secret. | Important | L1
[Azure.AppGw.SSLPolicy](../rules/Azure.AppGw.SSLPolicy.md) | Application Gateway should only accept a minimum of TLS 1.2. | Critical | L1
[Azure.AppGw.UseHTTPS](../rules/Azure.AppGw.UseHTTPS.md) | Application Gateways should only expose frontend HTTP endpoints over HTTPS. | Critical | L1
[Azure.AppInsights.LocalAuth](../rules/Azure.AppInsights.LocalAuth.md) | Local authentication allows depersonalized access to store telemetry in Application Insights using a shared identifier. | Critical | L1
[Azure.AppService.ManagedIdentity](../rules/Azure.AppService.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important | L1
[Azure.AppService.MinTLS](../rules/Azure.AppService.MinTLS.md) | App Service should not accept weak or deprecated transport protocols for client-server communication. | Critical | L1
[Azure.Automation.ManagedIdentity](../rules/Azure.Automation.ManagedIdentity.md) | Ensure Managed Identity is used for authentication. | Important | L1
[Azure.CDN.MinTLS](../rules/Azure.CDN.MinTLS.md) | Azure CDN endpoints should reject TLS versions older than 1.2. | Important | L1
[Azure.FrontDoor.MinTLS](../rules/Azure.FrontDoor.MinTLS.md) | Front Door Classic instances should reject TLS versions older than 1.2. | Critical | L1
[Azure.IoTHub.MinTLS](../rules/Azure.IoTHub.MinTLS.md) | IoT Hubs should reject TLS versions older than 1.2. | Critical | L1
[Azure.KeyVault.AccessPolicy](../rules/Azure.KeyVault.AccessPolicy.md) | Use the principal of least privilege when assigning access to Key Vault. | Important | L1
[Azure.KeyVault.Logs](../rules/Azure.KeyVault.Logs.md) | Ensure audit diagnostics logs are enabled to audit Key Vault access. | Important | L1
[Azure.KeyVault.RBAC](../rules/Azure.KeyVault.RBAC.md) | Key Vaults should use Azure RBAC as the authorization system for the data plane. | Awareness | L1
[Azure.MySQL.AAD](../rules/Azure.MySQL.AAD.md) | Use Entra ID authentication with Azure Database for MySQL databases. | Critical | L1
[Azure.MySQL.AADOnly](../rules/Azure.MySQL.AADOnly.md) | Ensure Entra ID only authentication is enabled with Azure Database for MySQL databases. | Important | L1
[Azure.PostgreSQL.AAD](../rules/Azure.PostgreSQL.AAD.md) | Use Entra ID authentication with Azure Database for PostgreSQL databases. | Critical | L1
[Azure.SQL.AAD](../rules/Azure.SQL.AAD.md) | Use Entra ID authentication with Azure SQL databases. | Critical | L1
[Azure.SQL.AADOnly](../rules/Azure.SQL.AADOnly.md) | Ensure Entra ID only authentication is enabled with Azure SQL Database. | Important | L1
[Azure.Storage.MinTLS](../rules/Azure.Storage.MinTLS.md) | Storage Accounts should not accept weak or deprecated transport protocols for client-server communication. | Critical | L1
[Azure.Storage.SecureTransfer](../rules/Azure.Storage.SecureTransfer.md) | Storage accounts should only accept encrypted connections. | Important | L1
