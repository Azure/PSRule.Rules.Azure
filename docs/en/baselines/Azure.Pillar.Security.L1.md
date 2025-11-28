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

This baseline includes a total of 85 rules.

Name | Synopsis | Severity | Maturity
---- | -------- | -------- | --------
[Azure.ACR.AdminUser](../rules/Azure.ACR.AdminUser.md) | The local admin account allows depersonalized access to a container registry using a shared secret. | Critical | L1
[Azure.ADX.DiskEncryption](../rules/Azure.ADX.DiskEncryption.md) | Use disk encryption for Azure Data Explorer (ADX) clusters. | Important | L1
[Azure.ADX.ManagedIdentity](../rules/Azure.ADX.ManagedIdentity.md) | Configure Data Explorer clusters to use managed identities to access Azure resources securely. | Important | L1
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
[Azure.AppConfig.AuditLogs](../rules/Azure.AppConfig.AuditLogs.md) | Ensure app configuration store audit diagnostic logs are enabled. | Important | L1
[Azure.AppConfig.DisableLocalAuth](../rules/Azure.AppConfig.DisableLocalAuth.md) | Access keys allow depersonalized access to App Configuration using a shared secret. | Important | L1
[Azure.AppConfig.ReplicaLocation](../rules/Azure.AppConfig.ReplicaLocation.md) | The replication location determines the country or region where configuration data is stored and processed. | Important | L1
[Azure.AppGw.SSLPolicy](../rules/Azure.AppGw.SSLPolicy.md) | Application Gateway should only accept a minimum of TLS 1.2. | Critical | L1
[Azure.AppGw.UseHTTPS](../rules/Azure.AppGw.UseHTTPS.md) | Application Gateways should only expose frontend HTTP endpoints over HTTPS. | Critical | L1
[Azure.AppInsights.LocalAuth](../rules/Azure.AppInsights.LocalAuth.md) | Local authentication allows depersonalized access to store telemetry in Application Insights using a shared identifier. | Critical | L1
[Azure.AppService.ManagedIdentity](../rules/Azure.AppService.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important | L1
[Azure.AppService.MinTLS](../rules/Azure.AppService.MinTLS.md) | App Service should not accept weak or deprecated transport protocols for client-server communication. | Critical | L1
[Azure.AppService.UseHTTPS](../rules/Azure.AppService.UseHTTPS.md) | Unencrypted communication could allow disclosure of information to an untrusted party. | Important | L1
[Azure.AppService.WebSecureFtp](../rules/Azure.AppService.WebSecureFtp.md) | Web apps should disable insecure FTP and configure SFTP when required. | Important | L1
[Azure.Automation.AuditLogs](../rules/Azure.Automation.AuditLogs.md) | Ensure automation account audit diagnostic logs are enabled. | Important | L1
[Azure.Automation.ManagedIdentity](../rules/Azure.Automation.ManagedIdentity.md) | Ensure Managed Identity is used for authentication. | Important | L1
[Azure.CDN.MinTLS](../rules/Azure.CDN.MinTLS.md) | Azure CDN endpoints should reject TLS versions older than 1.2. | Important | L1
[Azure.ContainerApp.Insecure](../rules/Azure.ContainerApp.Insecure.md) | Ensure insecure inbound traffic is not permitted to the container app. | Important | L1
[Azure.ContainerApp.ManagedIdentity](../rules/Azure.ContainerApp.ManagedIdentity.md) | Ensure managed identity is used for authentication. | Important | L1
[Azure.Cosmos.MinTLS](../rules/Azure.Cosmos.MinTLS.md) | Cosmos DB accounts should reject TLS versions older than 1.2. | Critical | L1
[Azure.Cosmos.MongoEntraID](../rules/Azure.Cosmos.MongoEntraID.md) | MongoDB vCore clusters should have Microsoft Entra ID authentication enabled. | Critical | L1
[Azure.Cosmos.NoSQLLocalAuth](../rules/Azure.Cosmos.NoSQLLocalAuth.md) | Access keys allow depersonalized access to Cosmos DB NoSQL API accounts using a shared secret. | Critical | L1
[Azure.EntraDS.NTLM](../rules/Azure.EntraDS.NTLM.md) | Disable NTLM v1 for Microsoft Entra Domain Services. | Critical | L1
[Azure.EntraDS.RC4](../rules/Azure.EntraDS.RC4.md) | Disable RC4 encryption for Microsoft Entra Domain Services. | Critical | L1
[Azure.EntraDS.TLS](../rules/Azure.EntraDS.TLS.md) | Disable TLS v1 for Microsoft Entra Domain Services. | Critical | L1
[Azure.EventGrid.DisableLocalAuth](../rules/Azure.EventGrid.DisableLocalAuth.md) | Authenticate publishing clients with Azure AD identities. | Important | L1
[Azure.EventGrid.DomainTLS](../rules/Azure.EventGrid.DomainTLS.md) | Weak or deprecated transport protocols for client-server communication introduce security vulnerabilities. | Critical | L1
[Azure.EventGrid.ManagedIdentity](../rules/Azure.EventGrid.ManagedIdentity.md) | Use managed identities to deliver Event Grid Topic events. | Important | L1
[Azure.EventGrid.NamespaceTLS](../rules/Azure.EventGrid.NamespaceTLS.md) | Weak or deprecated transport protocols for client-server communication introduce security vulnerabilities. | Critical | L1
[Azure.EventGrid.TopicTLS](../rules/Azure.EventGrid.TopicTLS.md) | Weak or deprecated transport protocols for client-server communication introduce security vulnerabilities. | Critical | L1
[Azure.EventHub.DisableLocalAuth](../rules/Azure.EventHub.DisableLocalAuth.md) | Authenticate Event Hub publishers and consumers with Entra ID identities. | Important | L1
[Azure.EventHub.MinTLS](../rules/Azure.EventHub.MinTLS.md) | Weak or deprecated transport protocols for client-server communication introduce security vulnerabilities. | Critical | L1
[Azure.FrontDoor.ManagedIdentity](../rules/Azure.FrontDoor.ManagedIdentity.md) | Ensure Front Door uses a managed identity to authorize access to Azure resources. | Important | L1
[Azure.FrontDoor.MinTLS](../rules/Azure.FrontDoor.MinTLS.md) | Front Door Classic instances should reject TLS versions older than 1.2. | Critical | L1
[Azure.IoTHub.MinTLS](../rules/Azure.IoTHub.MinTLS.md) | IoT Hubs should reject TLS versions older than 1.2. | Critical | L1
[Azure.KeyVault.AccessPolicy](../rules/Azure.KeyVault.AccessPolicy.md) | Use the principal of least privilege when assigning access to Key Vault. | Important | L1
[Azure.KeyVault.Logs](../rules/Azure.KeyVault.Logs.md) | Ensure audit diagnostics logs are enabled to audit Key Vault access. | Important | L1
[Azure.KeyVault.RBAC](../rules/Azure.KeyVault.RBAC.md) | Key Vaults should use Azure RBAC as the authorization system for the data plane. | Awareness | L1
[Azure.MariaDB.MinTLS](../rules/Azure.MariaDB.MinTLS.md) | Azure Database for MariaDB servers should reject TLS versions older than 1.2. | Critical | L1
[Azure.MariaDB.UseSSL](../rules/Azure.MariaDB.UseSSL.md) | Azure Database for MariaDB servers should only accept encrypted connections. | Critical | L1
[Azure.ML.DisableLocalAuth](../rules/Azure.ML.DisableLocalAuth.md) | Azure Machine Learning compute resources should have local authentication methods disabled. | Critical | L1
[Azure.ML.UserManagedIdentity](../rules/Azure.ML.UserManagedIdentity.md) | ML workspaces should use user-assigned managed identity, rather than the default system-assigned managed identity. | Important | L1
[Azure.MySQL.AAD](../rules/Azure.MySQL.AAD.md) | Use Entra ID authentication with Azure Database for MySQL databases. | Critical | L1
[Azure.MySQL.AADOnly](../rules/Azure.MySQL.AADOnly.md) | Ensure Entra ID only authentication is enabled with Azure Database for MySQL databases. | Important | L1
[Azure.MySQL.MinTLS](../rules/Azure.MySQL.MinTLS.md) | MySQL DB servers should reject TLS versions older than 1.2. | Critical | L1
[Azure.MySQL.UseSSL](../rules/Azure.MySQL.UseSSL.md) | Enforce encrypted MySQL connections. | Critical | L1
[Azure.PostgreSQL.AAD](../rules/Azure.PostgreSQL.AAD.md) | Use Entra ID authentication with Azure Database for PostgreSQL databases. | Critical | L1
[Azure.PostgreSQL.AADOnly](../rules/Azure.PostgreSQL.AADOnly.md) | Ensure Entra ID only authentication is enabled with Azure Database for PostgreSQL databases. | Important | L1
[Azure.PostgreSQL.MinTLS](../rules/Azure.PostgreSQL.MinTLS.md) | PostgreSQL DB servers should reject TLS versions older than 1.2. | Critical | L1
[Azure.PostgreSQL.UseSSL](../rules/Azure.PostgreSQL.UseSSL.md) | Enforce encrypted PostgreSQL connections. | Critical | L1
[Azure.Redis.EntraID](../rules/Azure.Redis.EntraID.md) | Use Entra ID authentication with cache instances. | Critical | L1
[Azure.Redis.LocalAuth](../rules/Azure.Redis.LocalAuth.md) | Access keys allow depersonalized access to Azure Cache for Redis using a shared secret. | Important | L1
[Azure.Redis.MinTLS](../rules/Azure.Redis.MinTLS.md) | Redis Cache should reject TLS versions older than 1.2. | Critical | L1
[Azure.Redis.NonSslPort](../rules/Azure.Redis.NonSslPort.md) | Azure Cache for Redis should only accept secure connections. | Critical | L1
[Azure.RedisEnterprise.MinTLS](../rules/Azure.RedisEnterprise.MinTLS.md) | Redis Cache should reject TLS versions older than 1.2. | Critical | L1
[Azure.Search.ManagedIdentity](../rules/Azure.Search.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important | L1
[Azure.ServiceBus.AuditLogs](../rules/Azure.ServiceBus.AuditLogs.md) | Ensure namespaces audit diagnostic logs are enabled. | Important | L1
[Azure.ServiceBus.DisableLocalAuth](../rules/Azure.ServiceBus.DisableLocalAuth.md) | Authenticate Service Bus publishers and consumers with Entra ID identities. | Important | L1
[Azure.ServiceBus.MinTLS](../rules/Azure.ServiceBus.MinTLS.md) | Service Bus namespaces should reject TLS versions older than 1.2. | Important | L1
[Azure.ServiceFabric.AAD](../rules/Azure.ServiceFabric.AAD.md) | Use Entra ID client authentication for Service Fabric clusters. | Critical | L1
[Azure.ServiceFabric.ProtectionLevel](../rules/Azure.ServiceFabric.ProtectionLevel.md) | Node to node communication that is not signed and encrypted may be susceptible to man-in-the-middle attacks. | Important | L1
[Azure.SignalR.ManagedIdentity](../rules/Azure.SignalR.ManagedIdentity.md) | Configure SignalR Services to use managed identities to access Azure resources securely. | Important | L1
[Azure.SQL.AAD](../rules/Azure.SQL.AAD.md) | Use Entra ID authentication with Azure SQL databases. | Critical | L1
[Azure.SQL.AADOnly](../rules/Azure.SQL.AADOnly.md) | Ensure Entra ID only authentication is enabled with Azure SQL Database. | Important | L1
[Azure.SQL.MinTLS](../rules/Azure.SQL.MinTLS.md) | Azure SQL Database servers should reject TLS versions older than 1.2. | Critical | L1
[Azure.SQL.TDE](../rules/Azure.SQL.TDE.md) | Use Transparent Data Encryption (TDE) with Azure SQL Database. | Critical | L1
[Azure.SQLMI.AAD](../rules/Azure.SQLMI.AAD.md) | Use Azure Active Directory (AAD) authentication with Azure SQL Managed Instance. | Critical | L1
[Azure.SQLMI.AADOnly](../rules/Azure.SQLMI.AADOnly.md) | Ensure Azure AD-only authentication is enabled with Azure SQL Managed Instance. | Important | L1
[Azure.SQLMI.ManagedIdentity](../rules/Azure.SQLMI.ManagedIdentity.md) | Ensure managed identity is used to allow support for Azure AD authentication. | Important | L1
[Azure.Storage.LocalAuth](../rules/Azure.Storage.LocalAuth.md) | Access keys allow depersonalized access to Storage Accounts using a shared secret. | Important | L1
[Azure.Storage.MinTLS](../rules/Azure.Storage.MinTLS.md) | Storage Accounts should not accept weak or deprecated transport protocols for client-server communication. | Critical | L1
[Azure.Storage.SecureTransfer](../rules/Azure.Storage.SecureTransfer.md) | Storage accounts should only accept encrypted connections. | Important | L1
[Azure.TrafficManager.Protocol](../rules/Azure.TrafficManager.Protocol.md) | Monitor Traffic Manager web-based endpoints with HTTPS. | Important | L1
[Azure.VM.ADE](../rules/Azure.VM.ADE.md) | Use Azure Disk Encryption (ADE). | Important | L1
[Azure.WebPubSub.ManagedIdentity](../rules/Azure.WebPubSub.ManagedIdentity.md) | Configure Web PubSub Services to use managed identities to access Azure resources securely. | Important | L1
