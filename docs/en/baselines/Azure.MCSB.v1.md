---
taxonomy: Azure.MCSB.v1
export: true
moduleVersion: v1.25.0
experimental: true
---

# Azure.MCSB.v1

<!-- EXPERIMENTAL -->

Rules for GA Azure features that align to the Microsoft Cloud Security Benchmark v1. This baseline is updated each release.

## Controls

The following rules are included within the `Azure.MCSB.v1` baseline.

This baseline includes a total of 137 rules.

Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.AdminUser](../rules/Azure.ACR.AdminUser.md) | The local admin account allows depersonalized access to a container registry using a shared secret. | Critical
[Azure.ACR.AnonymousAccess](../rules/Azure.ACR.AnonymousAccess.md) | Anonymous pull access allows unidentified downloading of images and metadata from a container registry. | Important
[Azure.ACR.ContainerScan](../rules/Azure.ACR.ContainerScan.md) | Container images or their base images may have vulnerabilities discovered after they are built. | Critical
[Azure.ACR.Firewall](../rules/Azure.ACR.Firewall.md) | Container Registry without restrictions can be accessed from any network location including the Internet. | Important
[Azure.ACR.ImageHealth](../rules/Azure.ACR.ImageHealth.md) | Remove container images with known vulnerabilities. | Critical
[Azure.ADX.DiskEncryption](../rules/Azure.ADX.DiskEncryption.md) | Use disk encryption for Azure Data Explorer (ADX) clusters. | Important
[Azure.ADX.ManagedIdentity](../rules/Azure.ADX.ManagedIdentity.md) | Configure Data Explorer clusters to use managed identities to access Azure resources securely. | Important
[Azure.AI.DisableLocalAuth](../rules/Azure.AI.DisableLocalAuth.md) | Access keys allow depersonalized access to Azure AI using a shared secret. | Important
[Azure.AI.ManagedIdentity](../rules/Azure.AI.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.AI.PrivateEndpoints](../rules/Azure.AI.PrivateEndpoints.md) | Use Private Endpoints to access Azure AI services accounts. | Important
[Azure.AI.PublicAccess](../rules/Azure.AI.PublicAccess.md) | Restrict access of Azure AI services to authorized virtual networks. | Important
[Azure.AKS.AuditLogs](../rules/Azure.AKS.AuditLogs.md) | AKS clusters should collect security-based audit logs to assess and monitor the compliance status of workloads. | Important
[Azure.AKS.AuthorizedIPs](../rules/Azure.AKS.AuthorizedIPs.md) | Restrict access to API server endpoints to authorized IP addresses. | Important
[Azure.AKS.AutoUpgrade](../rules/Azure.AKS.AutoUpgrade.md) | New versions of Kubernetes are released regularly. Upgrading each release manually can add operational overhead without realizing equivalent value. | Important
[Azure.AKS.AzurePolicyAddOn](../rules/Azure.AKS.AzurePolicyAddOn.md) | Configure Azure Kubernetes Service (AKS) clusters to use Azure Policy Add-on for Kubernetes. | Important
[Azure.AKS.AzureRBAC](../rules/Azure.AKS.AzureRBAC.md) | Use Azure RBAC for Kubernetes Authorization with AKS clusters. | Important
[Azure.AKS.ContainerInsights](../rules/Azure.AKS.ContainerInsights.md) | Enable Container insights to monitor AKS cluster workloads. | Important
[Azure.AKS.HttpAppRouting](../rules/Azure.AKS.HttpAppRouting.md) | Disable HTTP application routing add-on in AKS clusters. | Important
[Azure.AKS.LocalAccounts](../rules/Azure.AKS.LocalAccounts.md) | Enforce named user accounts with RBAC assigned permissions. | Important
[Azure.AKS.ManagedAAD](../rules/Azure.AKS.ManagedAAD.md) | Use AKS-managed Azure AD to simplify authorization and improve security. | Important
[Azure.AKS.ManagedIdentity](../rules/Azure.AKS.ManagedIdentity.md) | Configure AKS clusters to use managed identities for managing cluster infrastructure. | Important
[Azure.AKS.NetworkPolicy](../rules/Azure.AKS.NetworkPolicy.md) | AKS clusters without inter-pod network restrictions may be permit unauthorized lateral movement. | Important
[Azure.AKS.PlatformLogs](../rules/Azure.AKS.PlatformLogs.md) | AKS clusters should collect platform diagnostic logs to monitor the state of workloads. | Important
[Azure.AKS.SecretStore](../rules/Azure.AKS.SecretStore.md) | Deploy AKS clusters with Secrets Store CSI Driver and store Secrets in Key Vault. | Important
[Azure.AKS.SecretStoreRotation](../rules/Azure.AKS.SecretStoreRotation.md) | Enable autorotation of Secrets Store CSI Driver secrets for AKS clusters. | Important
[Azure.AKS.UseRBAC](../rules/Azure.AKS.UseRBAC.md) | Deploy AKS cluster with role-based access control (RBAC) enabled. | Important
[Azure.AKS.Version](../rules/Azure.AKS.Version.md) | Older versions of Kubernetes may have known bugs or security vulnerabilities, and may have limited support. | Important
[Azure.APIM.Ciphers](../rules/Azure.APIM.Ciphers.md) | API Management should not accept weak or deprecated ciphers for client or backend communication. | Critical
[Azure.APIM.DefenderCloud](../rules/Azure.APIM.DefenderCloud.md) | APIs published in Azure API Management should be onboarded to Microsoft Defender for APIs. | Critical
[Azure.APIM.EncryptValues](../rules/Azure.APIM.EncryptValues.md) | Encrypt all API Management named values with Key Vault secrets. | Important
[Azure.APIM.HTTPBackend](../rules/Azure.APIM.HTTPBackend.md) | Unencrypted communication could allow disclosure of information to an untrusted party. | Critical
[Azure.APIM.HTTPEndpoint](../rules/Azure.APIM.HTTPEndpoint.md) | Unencrypted communication could allow disclosure of information to an untrusted party. | Important
[Azure.APIM.ManagedIdentity](../rules/Azure.APIM.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.APIM.Protocols](../rules/Azure.APIM.Protocols.md) | API Management should only accept a minimum of TLS 1.2 for client and backend communication. | Critical
[Azure.AppConfig.AuditLogs](../rules/Azure.AppConfig.AuditLogs.md) | Ensure app configuration store audit diagnostic logs are enabled. | Important
[Azure.AppConfig.DisableLocalAuth](../rules/Azure.AppConfig.DisableLocalAuth.md) | Access keys allow depersonalized access to App Configuration using a shared secret. | Important
[Azure.AppConfig.SecretLeak](../rules/Azure.AppConfig.SecretLeak.md) | Secrets stored as key values in an App Configuration Store may be leaked to unauthorized users. | Critical
[Azure.AppGw.SSLPolicy](../rules/Azure.AppGw.SSLPolicy.md) | Application Gateway should only accept a minimum of TLS 1.2. | Critical
[Azure.AppGw.UseHTTPS](../rules/Azure.AppGw.UseHTTPS.md) | Application Gateways should only expose frontend HTTP endpoints over HTTPS. | Critical
[Azure.AppGw.UseWAF](../rules/Azure.AppGw.UseWAF.md) | Internet accessible Application Gateways should use protect endpoints with WAF. | Critical
[Azure.AppGw.WAFEnabled](../rules/Azure.AppGw.WAFEnabled.md) | Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources. | Critical
[Azure.AppService.ManagedIdentity](../rules/Azure.AppService.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.AppService.MinTLS](../rules/Azure.AppService.MinTLS.md) | App Service should not accept weak or deprecated transport protocols for client-server communication. | Critical
[Azure.AppService.RemoteDebug](../rules/Azure.AppService.RemoteDebug.md) | Disable remote debugging on App Service apps when not in use. | Important
[Azure.AppService.UseHTTPS](../rules/Azure.AppService.UseHTTPS.md) | Unencrypted communication could allow disclosure of information to an untrusted party. | Important
[Azure.AppService.WebSecureFtp](../rules/Azure.AppService.WebSecureFtp.md) | Web apps should disable insecure FTP and configure SFTP when required. | Important
[Azure.Automation.AuditLogs](../rules/Azure.Automation.AuditLogs.md) | Ensure automation account audit diagnostic logs are enabled. | Important
[Azure.Automation.EncryptVariables](../rules/Azure.Automation.EncryptVariables.md) | Azure Automation variables should be encrypted. | Important
[Azure.Automation.ManagedIdentity](../rules/Azure.Automation.ManagedIdentity.md) | Ensure Managed Identity is used for authentication. | Important
[Azure.BV.Immutable](../rules/Azure.BV.Immutable.md) | Ensure immutability is configured to protect backup data. | Important
[Azure.CDN.HTTP](../rules/Azure.CDN.HTTP.md) | Unencrypted communication could allow disclosure of information to an untrusted party. | Important
[Azure.ContainerApp.Insecure](../rules/Azure.ContainerApp.Insecure.md) | Ensure insecure inbound traffic is not permitted to the container app. | Important
[Azure.ContainerApp.ManagedIdentity](../rules/Azure.ContainerApp.ManagedIdentity.md) | Ensure managed identity is used for authentication. | Important
[Azure.ContainerApp.PublicAccess](../rules/Azure.ContainerApp.PublicAccess.md) | Ensure public network access for Container Apps environment is disabled. | Important
[Azure.ContainerApp.RestrictIngress](../rules/Azure.ContainerApp.RestrictIngress.md) | IP ingress restrictions mode should be set to allow action for all rules defined. | Important
[Azure.Cosmos.DefenderCloud](../rules/Azure.Cosmos.DefenderCloud.md) | Enable Microsoft Defender for Azure Cosmos DB. | Critical
[Azure.Cosmos.DisableLocalAuth](../rules/Azure.Cosmos.DisableLocalAuth.md) | Access keys allow depersonalized access to Cosmos DB accounts using a shared secret. | Critical
[Azure.Cosmos.DisableMetadataWrite](../rules/Azure.Cosmos.DisableMetadataWrite.md) | Use Entra ID identities for management place operations in Azure Cosmos DB. | Important
[Azure.Cosmos.PublicAccess](../rules/Azure.Cosmos.PublicAccess.md) | Azure Cosmos DB should have public network access disabled. | Critical
[Azure.Defender.Api](../rules/Azure.Defender.Api.md) | Enable Microsoft Defender for APIs. | Critical
[Azure.Defender.AppServices](../rules/Azure.Defender.AppServices.md) | Enable Microsoft Defender for App Service. | Critical
[Azure.Defender.Arm](../rules/Azure.Defender.Arm.md) | Enable Microsoft Defender for Azure Resource Manager (ARM). | Critical
[Azure.Defender.Containers](../rules/Azure.Defender.Containers.md) | Enable Microsoft Defender for Containers. | Critical
[Azure.Defender.CosmosDb](../rules/Azure.Defender.CosmosDb.md) | Enable Microsoft Defender for Azure Cosmos DB. | Critical
[Azure.Defender.Cspm](../rules/Azure.Defender.Cspm.md) | Enable Microsoft Defender Cloud Security Posture Management Standard plan. | Critical
[Azure.Defender.Dns](../rules/Azure.Defender.Dns.md) | Enable Microsoft Defender for DNS. | Critical
[Azure.Defender.KeyVault](../rules/Azure.Defender.KeyVault.md) | Enable Microsoft Defender for Key Vault. | Critical
[Azure.Defender.OssRdb](../rules/Azure.Defender.OssRdb.md) | Enable Microsoft Defender for open-source relational databases. | Critical
[Azure.Defender.Servers](../rules/Azure.Defender.Servers.md) | Enable Microsoft Defender for Servers. | Critical
[Azure.Defender.SQL](../rules/Azure.Defender.SQL.md) | Enable Microsoft Defender for SQL servers. | Critical
[Azure.Defender.SQLOnVM](../rules/Azure.Defender.SQLOnVM.md) | Enable Microsoft Defender for SQL servers on machines. | Critical
[Azure.Defender.Storage](../rules/Azure.Defender.Storage.md) | Enable Microsoft Defender for Storage. | Critical
[Azure.Defender.Storage.MalwareScan](../rules/Azure.Defender.Storage.MalwareScan.md) | Enable Malware Scanning in Microsoft Defender for Storage. | Critical
[Azure.DefenderCloud.Provisioning](../rules/Azure.DefenderCloud.Provisioning.md) | Enable auto-provisioning on to improve Microsoft Defender for Cloud insights. | Important
[Azure.EntraDS.TLS](../rules/Azure.EntraDS.TLS.md) | Disable TLS v1 for Microsoft Entra Domain Services. | Critical
[Azure.EventGrid.DisableLocalAuth](../rules/Azure.EventGrid.DisableLocalAuth.md) | Authenticate publishing clients with Azure AD identities. | Important
[Azure.EventGrid.ManagedIdentity](../rules/Azure.EventGrid.ManagedIdentity.md) | Use managed identities to deliver Event Grid Topic events. | Important
[Azure.EventGrid.TopicPublicAccess](../rules/Azure.EventGrid.TopicPublicAccess.md) | Use Private Endpoints to access Event Grid topics and domains. | Important
[Azure.EventHub.DisableLocalAuth](../rules/Azure.EventHub.DisableLocalAuth.md) | Authenticate Event Hub publishers and consumers with Entra ID identities. | Important
[Azure.EventHub.Firewall](../rules/Azure.EventHub.Firewall.md) | Access to the namespace endpoints should be restricted to only allowed sources. | Critical
[Azure.EventHub.MinTLS](../rules/Azure.EventHub.MinTLS.md) | Weak or deprecated transport protocols for client-server communication introduce security vulnerabilities. | Critical
[Azure.Firewall.PolicyMode](../rules/Azure.Firewall.PolicyMode.md) | Deny high confidence malicious IP addresses, domains and URLs. | Critical
[Azure.FrontDoor.Logs](../rules/Azure.FrontDoor.Logs.md) | Audit and monitor access through Azure Front Door profiles. | Important
[Azure.FrontDoor.ManagedIdentity](../rules/Azure.FrontDoor.ManagedIdentity.md) | Ensure Front Door uses a managed identity to authorize access to Azure resources. | Important
[Azure.FrontDoor.MinTLS](../rules/Azure.FrontDoor.MinTLS.md) | Front Door Classic instances should reject TLS versions older than 1.2. | Critical
[Azure.FrontDoor.UseWAF](../rules/Azure.FrontDoor.UseWAF.md) | Enable Web Application Firewall (WAF) policies on each Front Door endpoint. | Critical
[Azure.FrontDoor.WAF.Enabled](../rules/Azure.FrontDoor.WAF.Enabled.md) | Front Door Web Application Firewall (WAF) policy must be enabled to protect back end resources. | Critical
[Azure.IoTHub.MinTLS](../rules/Azure.IoTHub.MinTLS.md) | IoT Hubs should reject TLS versions older than 1.2. | Critical
[Azure.KeyVault.Firewall](../rules/Azure.KeyVault.Firewall.md) | Key Vault should only accept explicitly allowed traffic. | Important
[Azure.KeyVault.Logs](../rules/Azure.KeyVault.Logs.md) | Ensure audit diagnostics logs are enabled to audit Key Vault access. | Important
[Azure.KeyVault.RBAC](../rules/Azure.KeyVault.RBAC.md) | Key Vaults should use Azure RBAC as the authorization system for the data plane. | Awareness
[Azure.ML.ComputeVnet](../rules/Azure.ML.ComputeVnet.md) | Azure Machine Learning Computes should be hosted in a virtual network (VNet). | Critical
[Azure.ML.PublicAccess](../rules/Azure.ML.PublicAccess.md) | Disable public network access from a Azure Machine Learning workspace. | Critical
[Azure.ML.UserManagedIdentity](../rules/Azure.ML.UserManagedIdentity.md) | ML workspaces should use user-assigned managed identity, rather than the default system-assigned managed identity. | Important
[Azure.MySQL.AAD](../rules/Azure.MySQL.AAD.md) | Use Entra ID authentication with Azure Database for MySQL databases. | Critical
[Azure.MySQL.AADOnly](../rules/Azure.MySQL.AADOnly.md) | Ensure Entra ID only authentication is enabled with Azure Database for MySQL databases. | Important
[Azure.MySQL.MinTLS](../rules/Azure.MySQL.MinTLS.md) | MySQL DB servers should reject TLS versions older than 1.2. | Critical
[Azure.MySQL.UseSSL](../rules/Azure.MySQL.UseSSL.md) | Enforce encrypted MySQL connections. | Critical
[Azure.PostgreSQL.AAD](../rules/Azure.PostgreSQL.AAD.md) | Use Entra ID authentication with Azure Database for PostgreSQL databases. | Critical
[Azure.PostgreSQL.AADOnly](../rules/Azure.PostgreSQL.AADOnly.md) | Ensure Entra ID only authentication is enabled with Azure Database for PostgreSQL databases. | Important
[Azure.PostgreSQL.MinTLS](../rules/Azure.PostgreSQL.MinTLS.md) | PostgreSQL DB servers should reject TLS versions older than 1.2. | Critical
[Azure.PostgreSQL.UseSSL](../rules/Azure.PostgreSQL.UseSSL.md) | Enforce encrypted PostgreSQL connections. | Critical
[Azure.PublicIP.IsAttached](../rules/Azure.PublicIP.IsAttached.md) | Public IP addresses should be attached or cleaned up if not in use. | Important
[Azure.RBAC.CoAdministrator](../rules/Azure.RBAC.CoAdministrator.md) | Delegate access to manage Azure resources using role-based access control (RBAC). | Important
[Azure.RBAC.LimitMGDelegation](../rules/Azure.RBAC.LimitMGDelegation.md) | Limit Role-Base Access Control (RBAC) inheritance from Management Groups. | Important
[Azure.RBAC.LimitOwner](../rules/Azure.RBAC.LimitOwner.md) | Limit the number of subscription Owners. | Important
[Azure.RBAC.PIM](../rules/Azure.RBAC.PIM.md) | Use just-in-time (JiT) activation of roles instead of persistent role assignment. | Important
[Azure.RBAC.UseGroups](../rules/Azure.RBAC.UseGroups.md) | Use groups for assigning permissions instead of individual user accounts. | Important
[Azure.RBAC.UseRGDelegation](../rules/Azure.RBAC.UseRGDelegation.md) | Use RBAC assignments on resource groups instead of individual resources. | Important
[Azure.Redis.EntraID](../rules/Azure.Redis.EntraID.md) | Use Entra ID authentication with cache instances. | Critical
[Azure.Redis.MinTLS](../rules/Azure.Redis.MinTLS.md) | Redis Cache should reject TLS versions older than 1.2. | Critical
[Azure.Redis.NonSslPort](../rules/Azure.Redis.NonSslPort.md) | Azure Cache for Redis should only accept secure connections. | Critical
[Azure.Redis.PublicNetworkAccess](../rules/Azure.Redis.PublicNetworkAccess.md) | Redis cache should disable public network access. | Critical
[Azure.RedisEnterprise.MinTLS](../rules/Azure.RedisEnterprise.MinTLS.md) | Redis Cache should reject TLS versions older than 1.2. | Critical
[Azure.RSV.Immutable](../rules/Azure.RSV.Immutable.md) | Ensure immutability is configured to protect backup data. | Important
[Azure.Search.ManagedIdentity](../rules/Azure.Search.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.ServiceBus.DisableLocalAuth](../rules/Azure.ServiceBus.DisableLocalAuth.md) | Authenticate Service Bus publishers and consumers with Entra ID identities. | Important
[Azure.ServiceBus.MinTLS](../rules/Azure.ServiceBus.MinTLS.md) | Service Bus namespaces should reject TLS versions older than 1.2. | Important
[Azure.ServiceFabric.AAD](../rules/Azure.ServiceFabric.AAD.md) | Use Entra ID client authentication for Service Fabric clusters. | Critical
[Azure.SignalR.ManagedIdentity](../rules/Azure.SignalR.ManagedIdentity.md) | Configure SignalR Services to use managed identities to access Azure resources securely. | Important
[Azure.SQL.AAD](../rules/Azure.SQL.AAD.md) | Use Entra ID authentication with Azure SQL databases. | Critical
[Azure.SQL.Auditing](../rules/Azure.SQL.Auditing.md) | Enable auditing for Azure SQL logical server. | Important
[Azure.SQL.DefenderCloud](../rules/Azure.SQL.DefenderCloud.md) | Enable Microsoft Defender for Azure SQL logical server. | Important
[Azure.SQL.MinTLS](../rules/Azure.SQL.MinTLS.md) | Azure SQL Database servers should reject TLS versions older than 1.2. | Critical
[Azure.SQL.TDE](../rules/Azure.SQL.TDE.md) | Use Transparent Data Encryption (TDE) with Azure SQL Database. | Critical
[Azure.SQLMI.AAD](../rules/Azure.SQLMI.AAD.md) | Use Azure Active Directory (AAD) authentication with Azure SQL Managed Instance. | Critical
[Azure.SQLMI.ManagedIdentity](../rules/Azure.SQLMI.ManagedIdentity.md) | Ensure managed identity is used to allow support for Azure AD authentication. | Important
[Azure.Storage.BlobPublicAccess](../rules/Azure.Storage.BlobPublicAccess.md) | Storage Accounts should only accept authorized requests. | Important
[Azure.Storage.Defender.MalwareScan](../rules/Azure.Storage.Defender.MalwareScan.md) | Enable Malware Scanning in Microsoft Defender for Storage. | Critical
[Azure.Storage.DefenderCloud](../rules/Azure.Storage.DefenderCloud.md) | Enable Microsoft Defender for Storage for storage accounts. | Critical
[Azure.Storage.MinTLS](../rules/Azure.Storage.MinTLS.md) | Storage Accounts should not accept weak or deprecated transport protocols for client-server communication. | Critical
[Azure.Storage.SecureTransfer](../rules/Azure.Storage.SecureTransfer.md) | Storage accounts should only accept encrypted connections. | Important
[Azure.VM.ADE](../rules/Azure.VM.ADE.md) | Use Azure Disk Encryption (ADE). | Important
[Azure.VM.Updates](../rules/Azure.VM.Updates.md) | Ensure automatic updates are enabled at deployment. | Important
[Azure.VM.UseManagedDisks](../rules/Azure.VM.UseManagedDisks.md) | Virtual machines (VMs) should use managed disks. | Important
[Azure.VMSS.PublicKey](../rules/Azure.VMSS.PublicKey.md) | Use SSH keys instead of common credentials to secure virtual machine scale sets against malicious activities. | Important
[Azure.WebPubSub.ManagedIdentity](../rules/Azure.WebPubSub.ManagedIdentity.md) | Configure Web PubSub Services to use managed identities to access Azure resources securely. | Important
