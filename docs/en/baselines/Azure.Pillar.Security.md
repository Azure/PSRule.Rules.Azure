---
taxonomy: Azure.WAF
pillar: Security
export: true
moduleVersion: v1.35.0
---

# Azure.Pillar.Security

Microsoft Azure Well-Architected Framework - Security pillar specific baseline.

## Rules

The following rules are included within the `Azure.Pillar.Security` baseline.

This baseline includes a total of 209 rules.

Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.AdminUser](../rules/Azure.ACR.AdminUser.md) | Use Entra ID identities instead of using the registry admin user. | Critical
[Azure.ACR.ContainerScan](../rules/Azure.ACR.ContainerScan.md) | Enable vulnerability scanning for container images. | Critical
[Azure.ACR.ContentTrust](../rules/Azure.ACR.ContentTrust.md) | Use container images signed by a trusted image publisher. | Important
[Azure.ACR.Firewall](../rules/Azure.ACR.Firewall.md) | Limit network access of container registries to only trusted clients. | Important
[Azure.ACR.ImageHealth](../rules/Azure.ACR.ImageHealth.md) | Remove container images with known vulnerabilities. | Critical
[Azure.ADX.DiskEncryption](../rules/Azure.ADX.DiskEncryption.md) | Use disk encryption for Azure Data Explorer (ADX) clusters. | Important
[Azure.ADX.ManagedIdentity](../rules/Azure.ADX.ManagedIdentity.md) | Configure Data Explorer clusters to use managed identities to access Azure resources securely. | Important
[Azure.AI.DisableLocalAuth](../rules/Azure.AI.DisableLocalAuth.md) | Authenticate requests to Azure AI services with Entra ID identities. | Important
[Azure.AI.ManagedIdentity](../rules/Azure.AI.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.AI.PrivateEndpoints](../rules/Azure.AI.PrivateEndpoints.md) | Use Private Endpoints to access Azure AI services accounts. | Important
[Azure.AI.PublicAccess](../rules/Azure.AI.PublicAccess.md) | Restrict access of Azure AI services to authorized virtual networks. | Important
[Azure.AKS.AuditLogs](../rules/Azure.AKS.AuditLogs.md) | AKS clusters should collect security-based audit logs to assess and monitor the compliance status of workloads. | Important
[Azure.AKS.AuthorizedIPs](../rules/Azure.AKS.AuthorizedIPs.md) | Restrict access to API server endpoints to authorized IP addresses. | Important
[Azure.AKS.AutoUpgrade](../rules/Azure.AKS.AutoUpgrade.md) | Configure AKS to automatically upgrade to newer supported AKS versions as they are made available. | Important
[Azure.AKS.AzurePolicyAddOn](../rules/Azure.AKS.AzurePolicyAddOn.md) | Configure Azure Kubernetes Service (AKS) clusters to use Azure Policy Add-on for Kubernetes. | Important
[Azure.AKS.AzureRBAC](../rules/Azure.AKS.AzureRBAC.md) | Use Azure RBAC for Kubernetes Authorization with AKS clusters. | Important
[Azure.AKS.DefenderProfile](../rules/Azure.AKS.DefenderProfile.md) | Enable the Defender profile with Azure Kubernetes Service (AKS) cluster. | Important
[Azure.AKS.HttpAppRouting](../rules/Azure.AKS.HttpAppRouting.md) | Disable HTTP application routing add-on in AKS clusters. | Important
[Azure.AKS.LocalAccounts](../rules/Azure.AKS.LocalAccounts.md) | Enforce named user accounts with RBAC assigned permissions. | Important
[Azure.AKS.ManagedAAD](../rules/Azure.AKS.ManagedAAD.md) | Use AKS-managed Azure AD to simplify authorization and improve security. | Important
[Azure.AKS.ManagedIdentity](../rules/Azure.AKS.ManagedIdentity.md) | Configure AKS clusters to use managed identities for managing cluster infrastructure. | Important
[Azure.AKS.NetworkPolicy](../rules/Azure.AKS.NetworkPolicy.md) | Deploy AKS clusters with Network Policies enabled. | Important
[Azure.AKS.NodeAutoUpgrade](../rules/Azure.AKS.NodeAutoUpgrade.md) | Deploy AKS Clusters with Node Auto-Upgrade enabled | Important
[Azure.AKS.SecretStore](../rules/Azure.AKS.SecretStore.md) | Deploy AKS clusters with Secrets Store CSI Driver and store Secrets in Key Vault. | Important
[Azure.AKS.SecretStoreRotation](../rules/Azure.AKS.SecretStoreRotation.md) | Enable autorotation of Secrets Store CSI Driver secrets for AKS clusters. | Important
[Azure.AKS.UseRBAC](../rules/Azure.AKS.UseRBAC.md) | Deploy AKS cluster with role-based access control (RBAC) enabled. | Important
[Azure.APIM.CertificateExpiry](../rules/Azure.APIM.CertificateExpiry.md) | Renew certificates used for custom domain bindings. | Important
[Azure.APIM.Ciphers](../rules/Azure.APIM.Ciphers.md) | API Management should not accept weak or deprecated ciphers for client or backend communication. | Critical
[Azure.APIM.CORSPolicy](../rules/Azure.APIM.CORSPolicy.md) | Avoid using wildcard for any configuration option in CORS policies. | Important
[Azure.APIM.DefenderCloud](../rules/Azure.APIM.DefenderCloud.md) | APIs published in Azure API Management should be onboarded to Microsoft Defender for APIs. | Critical
[Azure.APIM.EncryptValues](../rules/Azure.APIM.EncryptValues.md) | Encrypt all API Management named values with Key Vault secrets. | Important
[Azure.APIM.HTTPBackend](../rules/Azure.APIM.HTTPBackend.md) | Use HTTPS for communication to backend services. | Critical
[Azure.APIM.HTTPEndpoint](../rules/Azure.APIM.HTTPEndpoint.md) | Enforce HTTPS for communication to API clients. | Important
[Azure.APIM.ManagedIdentity](../rules/Azure.APIM.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.APIM.PolicyBase](../rules/Azure.APIM.PolicyBase.md) | Base element for any policy element in a section should be configured. | Important
[Azure.APIM.ProductApproval](../rules/Azure.APIM.ProductApproval.md) | Configure products to require approval. | Important
[Azure.APIM.ProductSubscription](../rules/Azure.APIM.ProductSubscription.md) | Configure products to require a subscription. | Important
[Azure.APIM.Protocols](../rules/Azure.APIM.Protocols.md) | API Management should only accept a minimum of TLS 1.2 for client and backend communication. | Critical
[Azure.AppConfig.AuditLogs](../rules/Azure.AppConfig.AuditLogs.md) | Ensure app configuration store audit diagnostic logs are enabled. | Important
[Azure.AppConfig.DisableLocalAuth](../rules/Azure.AppConfig.DisableLocalAuth.md) | Authenticate App Configuration clients with Entra ID identities. | Important
[Azure.AppGw.OWASP](../rules/Azure.AppGw.OWASP.md) | Application Gateway Web Application Firewall (WAF) should use OWASP 3.x rules. | Important
[Azure.AppGw.Prevention](../rules/Azure.AppGw.Prevention.md) | Internet exposed Application Gateways should use prevention mode to protect backend resources. | Critical
[Azure.AppGw.SSLPolicy](../rules/Azure.AppGw.SSLPolicy.md) | Application Gateway should only accept a minimum of TLS 1.2. | Critical
[Azure.AppGw.UseHTTPS](../rules/Azure.AppGw.UseHTTPS.md) | Application Gateways should only expose frontend HTTP endpoints over HTTPS. | Critical
[Azure.AppGw.UseWAF](../rules/Azure.AppGw.UseWAF.md) | Internet accessible Application Gateways should use protect endpoints with WAF. | Critical
[Azure.AppGw.WAFEnabled](../rules/Azure.AppGw.WAFEnabled.md) | Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources. | Critical
[Azure.AppGw.WAFRules](../rules/Azure.AppGw.WAFRules.md) | Application Gateway Web Application Firewall (WAF) should have all rules enabled. | Important
[Azure.AppGwWAF.Enabled](../rules/Azure.AppGwWAF.Enabled.md) | Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources. | Critical
[Azure.AppGwWAF.Exclusions](../rules/Azure.AppGwWAF.Exclusions.md) | Application Gateway Web Application Firewall (WAF) should have all rules enabled. | Critical
[Azure.AppGwWAF.PreventionMode](../rules/Azure.AppGwWAF.PreventionMode.md) | Use protection mode in Application Gateway Web Application Firewall (WAF) policies to protect back end resources. | Critical
[Azure.AppGwWAF.RuleGroups](../rules/Azure.AppGwWAF.RuleGroups.md) | Use recommended rule groups in Application Gateway Web Application Firewall (WAF) policies to protect back end resources. | Critical
[Azure.AppService.ManagedIdentity](../rules/Azure.AppService.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.AppService.MinTLS](../rules/Azure.AppService.MinTLS.md) | App Service should reject TLS versions older than 1.2. | Critical
[Azure.AppService.NETVersion](../rules/Azure.AppService.NETVersion.md) | Configure applications to use newer .NET versions. | Important
[Azure.AppService.NodeJsVersion](../rules/Azure.AppService.NodeJsVersion.md) | Configure applications to use supported Node.js runtime versions. | Important
[Azure.AppService.PHPVersion](../rules/Azure.AppService.PHPVersion.md) | Configure applications to use newer PHP runtime versions. | Important
[Azure.AppService.RemoteDebug](../rules/Azure.AppService.RemoteDebug.md) | Disable remote debugging on App Service apps when not in use. | Important
[Azure.AppService.UseHTTPS](../rules/Azure.AppService.UseHTTPS.md) | Azure App Service apps should only accept encrypted connections. | Important
[Azure.AppService.WebSecureFtp](../rules/Azure.AppService.WebSecureFtp.md) | Web apps should disable insecure FTP and configure SFTP when required. | Important
[Azure.Automation.AuditLogs](../rules/Azure.Automation.AuditLogs.md) | Ensure automation account audit diagnostic logs are enabled. | Important
[Azure.Automation.EncryptVariables](../rules/Azure.Automation.EncryptVariables.md) | Azure Automation variables should be encrypted. | Important
[Azure.Automation.ManagedIdentity](../rules/Azure.Automation.ManagedIdentity.md) | Ensure Managed Identity is used for authentication. | Important
[Azure.Automation.WebHookExpiry](../rules/Azure.Automation.WebHookExpiry.md) | Do not create webhooks with an expiry time greater than 1 year (default). | Awareness
[Azure.BV.Immutable](../rules/Azure.BV.Immutable.md) | Ensure immutability is configured to protect backup data. | Important
[Azure.CDN.HTTP](../rules/Azure.CDN.HTTP.md) | Enforce HTTPS for client connections. | Important
[Azure.CDN.MinTLS](../rules/Azure.CDN.MinTLS.md) | Azure CDN endpoints should reject TLS versions older than 1.2. | Important
[Azure.ContainerApp.ExternalIngress](../rules/Azure.ContainerApp.ExternalIngress.md) | Limit inbound communication for Container Apps is limited to callers within the Container Apps Environment. | Important
[Azure.ContainerApp.Insecure](../rules/Azure.ContainerApp.Insecure.md) | Ensure insecure inbound traffic is not permitted to the container app. | Important
[Azure.ContainerApp.ManagedIdentity](../rules/Azure.ContainerApp.ManagedIdentity.md) | Ensure managed identity is used for authentication. | Important
[Azure.ContainerApp.PublicAccess](../rules/Azure.ContainerApp.PublicAccess.md) | Ensure public network access for Container Apps environment is disabled. | Important
[Azure.ContainerApp.RestrictIngress](../rules/Azure.ContainerApp.RestrictIngress.md) | IP ingress restrictions mode should be set to allow action for all rules defined. | Important
[Azure.Cosmos.DefenderCloud](../rules/Azure.Cosmos.DefenderCloud.md) | Enable Microsoft Defender for Azure Cosmos DB. | Critical
[Azure.Cosmos.DisableLocalAuth](../rules/Azure.Cosmos.DisableLocalAuth.md) | Azure Cosmos DB should have local authentication disabled. | Critical
[Azure.Cosmos.DisableMetadataWrite](../rules/Azure.Cosmos.DisableMetadataWrite.md) | Use Entra ID identities for management place operations in Azure Cosmos DB. | Important
[Azure.Cosmos.MinTLS](../rules/Azure.Cosmos.MinTLS.md) | Cosmos DB accounts should reject TLS versions older than 1.2. | Critical
[Azure.Cosmos.PublicAccess](../rules/Azure.Cosmos.PublicAccess.md) | Azure Cosmos DB should have public network access disabled. | Critical
[Azure.Databricks.PublicAccess](../rules/Azure.Databricks.PublicAccess.md) | Azure Databricks workspaces should disable public network access. | Critical
[Azure.Databricks.SecureConnectivity](../rules/Azure.Databricks.SecureConnectivity.md) | Use Databricks workspaces configured for secure cluster connectivity. | Critical
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
[Azure.DefenderCloud.Contact](../rules/Azure.DefenderCloud.Contact.md) | Microsoft Defender for Cloud email and phone contact details should be set. | Important
[Azure.DefenderCloud.Provisioning](../rules/Azure.DefenderCloud.Provisioning.md) | Enable auto-provisioning on to improve Microsoft Defender for Cloud insights. | Important
[Azure.Deployment.AdminUsername](../rules/Azure.Deployment.AdminUsername.md) | Use secure parameters for sensitive resource properties. | Awareness
[Azure.Deployment.OuterSecret](../rules/Azure.Deployment.OuterSecret.md) | Do not use Outer deployments when references SecureString or SecureObject parameters. | Critical
[Azure.Deployment.OutputSecretValue](../rules/Azure.Deployment.OutputSecretValue.md) | Avoid outputting sensitive deployment values. | Critical
[Azure.Deployment.SecureParameter](../rules/Azure.Deployment.SecureParameter.md) | Use secure parameters for any parameter that contains sensitive information. | Critical
[Azure.Deployment.SecureValue](../rules/Azure.Deployment.SecureValue.md) | Use secure parameters for setting properties of resources that contain sensitive information. | Critical
[Azure.EntraDS.NTLM](../rules/Azure.EntraDS.NTLM.md) | Disable NTLM v1 for Microsoft Entra Domain Services. | Critical
[Azure.EntraDS.RC4](../rules/Azure.EntraDS.RC4.md) | Disable RC4 encryption for Microsoft Entra Domain Services. | Critical
[Azure.EntraDS.TLS](../rules/Azure.EntraDS.TLS.md) | Disable TLS v1 for Microsoft Entra Domain Services. | Critical
[Azure.EventGrid.DisableLocalAuth](../rules/Azure.EventGrid.DisableLocalAuth.md) | Authenticate publishing clients with Azure AD identities. | Important
[Azure.EventGrid.ManagedIdentity](../rules/Azure.EventGrid.ManagedIdentity.md) | Use managed identities to deliver Event Grid Topic events. | Important
[Azure.EventGrid.TopicPublicAccess](../rules/Azure.EventGrid.TopicPublicAccess.md) | Use Private Endpoints to access Event Grid topics and domains. | Important
[Azure.EventHub.DisableLocalAuth](../rules/Azure.EventHub.DisableLocalAuth.md) | Authenticate Event Hub publishers and consumers with Entra ID identities. | Important
[Azure.EventHub.Firewall](../rules/Azure.EventHub.Firewall.md) | Access to the namespace endpoints should be restricted to only allowed sources. | Critical
[Azure.EventHub.MinTLS](../rules/Azure.EventHub.MinTLS.md) | Event Hub namespaces should reject TLS versions older than 1.2. | Critical
[Azure.Firewall.Mode](../rules/Azure.Firewall.Mode.md) | Deny high confidence malicious IP addresses and domains on classic managed Azure Firewalls. | Critical
[Azure.Firewall.PolicyMode](../rules/Azure.Firewall.PolicyMode.md) | Deny high confidence malicious IP addresses, domains and URLs. | Critical
[Azure.FrontDoor.Logs](../rules/Azure.FrontDoor.Logs.md) | Audit and monitor access through Azure Front Door profiles. | Important
[Azure.FrontDoor.ManagedIdentity](../rules/Azure.FrontDoor.ManagedIdentity.md) | Ensure Front Door uses a managed identity to authorize access to Azure resources. | Important
[Azure.FrontDoor.MinTLS](../rules/Azure.FrontDoor.MinTLS.md) | Front Door Classic instances should reject TLS versions older than 1.2. | Critical
[Azure.FrontDoor.UseWAF](../rules/Azure.FrontDoor.UseWAF.md) | Enable Web Application Firewall (WAF) policies on each Front Door endpoint. | Critical
[Azure.FrontDoor.WAF.Enabled](../rules/Azure.FrontDoor.WAF.Enabled.md) | Front Door Web Application Firewall (WAF) policy must be enabled to protect back end resources. | Critical
[Azure.FrontDoor.WAF.Mode](../rules/Azure.FrontDoor.WAF.Mode.md) | Use protection mode in Front Door Web Application Firewall (WAF) policies to protect back end resources. | Critical
[Azure.FrontDoorWAF.Enabled](../rules/Azure.FrontDoorWAF.Enabled.md) | Front Door Web Application Firewall (WAF) policy must be enabled to protect back end resources. | Critical
[Azure.FrontDoorWAF.Exclusions](../rules/Azure.FrontDoorWAF.Exclusions.md) | Use recommended rule groups in Front Door Web Application Firewall (WAF) policies to protect back end resources. Avoid configuring rule exclusions. | Critical
[Azure.FrontDoorWAF.PreventionMode](../rules/Azure.FrontDoorWAF.PreventionMode.md) | Use protection mode in Front Door Web Application Firewall (WAF) policies to protect back end resources. | Critical
[Azure.FrontDoorWAF.RuleGroups](../rules/Azure.FrontDoorWAF.RuleGroups.md) | Use recommended rule groups in Front Door Web Application Firewall (WAF) policies to protect back end resources. | Critical
[Azure.IoTHub.MinTLS](../rules/Azure.IoTHub.MinTLS.md) | IoT Hubs should reject TLS versions older than 1.2. | Critical
[Azure.KeyVault.AccessPolicy](../rules/Azure.KeyVault.AccessPolicy.md) | Use the principal of least privilege when assigning access to Key Vault. | Important
[Azure.KeyVault.AutoRotationPolicy](../rules/Azure.KeyVault.AutoRotationPolicy.md) | Key Vault keys should have auto-rotation enabled. | Important
[Azure.KeyVault.Firewall](../rules/Azure.KeyVault.Firewall.md) | Key Vault should only accept explicitly allowed traffic. | Important
[Azure.KeyVault.Logs](../rules/Azure.KeyVault.Logs.md) | Ensure audit diagnostics logs are enabled to audit Key Vault access. | Important
[Azure.KeyVault.RBAC](../rules/Azure.KeyVault.RBAC.md) | Key Vaults should use Azure RBAC as the authorization system for the data plane. | Awareness
[Azure.LogicApp.LimitHTTPTrigger](../rules/Azure.LogicApp.LimitHTTPTrigger.md) | Limit HTTP request trigger access to trusted IP addresses. | Critical
[Azure.MariaDB.AllowAzureAccess](../rules/Azure.MariaDB.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.MariaDB.DefenderCloud](../rules/Azure.MariaDB.DefenderCloud.md) | Enable Microsoft Defender for Cloud for Azure Database for MariaDB. | Important
[Azure.MariaDB.FirewallIPRange](../rules/Azure.MariaDB.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important
[Azure.MariaDB.FirewallRuleCount](../rules/Azure.MariaDB.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
[Azure.MariaDB.MinTLS](../rules/Azure.MariaDB.MinTLS.md) | Azure Database for MariaDB servers should reject TLS versions older than 1.2. | Critical
[Azure.MariaDB.UseSSL](../rules/Azure.MariaDB.UseSSL.md) | Azure Database for MariaDB servers should only accept encrypted connections. | Critical
[Azure.ML.ComputeVnet](../rules/Azure.ML.ComputeVnet.md) | Azure Machine Learning Computes should be hosted in a virtual network (VNet). | Critical
[Azure.ML.DisableLocalAuth](../rules/Azure.ML.DisableLocalAuth.md) | Azure Machine Learning compute resources should have local authentication methods disabled. | Critical
[Azure.ML.PublicAccess](../rules/Azure.ML.PublicAccess.md) | Disable public network access from a Azure Machine Learning workspace. | Critical
[Azure.ML.UserManagedIdentity](../rules/Azure.ML.UserManagedIdentity.md) | ML workspaces should use user-assigned managed identity, rather than the default system-assigned managed identity. | Important
[Azure.Monitor.ServiceHealth](../rules/Azure.Monitor.ServiceHealth.md) | Configure Service Health alerts to notify administrators. | Important
[Azure.MySQL.AAD](../rules/Azure.MySQL.AAD.md) | Use Entra ID authentication with Azure Database for MySQL databases. | Critical
[Azure.MySQL.AADOnly](../rules/Azure.MySQL.AADOnly.md) | Ensure Entra ID only authentication is enabled with Azure Database for MySQL databases. | Important
[Azure.MySQL.AllowAzureAccess](../rules/Azure.MySQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.MySQL.DefenderCloud](../rules/Azure.MySQL.DefenderCloud.md) | Enable Microsoft Defender for Cloud for Azure Database for MySQL. | Important
[Azure.MySQL.FirewallIPRange](../rules/Azure.MySQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important
[Azure.MySQL.FirewallRuleCount](../rules/Azure.MySQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
[Azure.MySQL.MinTLS](../rules/Azure.MySQL.MinTLS.md) | MySQL DB servers should reject TLS versions older than 1.2. | Critical
[Azure.MySQL.UseSSL](../rules/Azure.MySQL.UseSSL.md) | Enforce encrypted MySQL connections. | Critical
[Azure.NSG.AnyInboundSource](../rules/Azure.NSG.AnyInboundSource.md) | Network security groups (NSGs) should avoid rules that allow "any" as an inbound source. | Critical
[Azure.NSG.DenyAllInbound](../rules/Azure.NSG.DenyAllInbound.md) | Avoid denying all inbound traffic. | Important
[Azure.NSG.LateralTraversal](../rules/Azure.NSG.LateralTraversal.md) | Deny outbound management connections from non-management hosts. | Important
[Azure.PostgreSQL.AAD](../rules/Azure.PostgreSQL.AAD.md) | Use Entra ID authentication with Azure Database for PostgreSQL databases. | Critical
[Azure.PostgreSQL.AADOnly](../rules/Azure.PostgreSQL.AADOnly.md) | Ensure Entra ID only authentication is enabled with Azure Database for PostgreSQL databases. | Important
[Azure.PostgreSQL.AllowAzureAccess](../rules/Azure.PostgreSQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.PostgreSQL.DefenderCloud](../rules/Azure.PostgreSQL.DefenderCloud.md) | Enable Microsoft Defender for Cloud for Azure Database for PostgreSQL. | Important
[Azure.PostgreSQL.FirewallIPRange](../rules/Azure.PostgreSQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important
[Azure.PostgreSQL.FirewallRuleCount](../rules/Azure.PostgreSQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
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
[Azure.Redis.FirewallIPRange](../rules/Azure.Redis.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses for the Redis cache. | Critical
[Azure.Redis.FirewallRuleCount](../rules/Azure.Redis.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules for the Redis cache. | Awareness
[Azure.Redis.MinTLS](../rules/Azure.Redis.MinTLS.md) | Redis Cache should reject TLS versions older than 1.2. | Critical
[Azure.Redis.NonSslPort](../rules/Azure.Redis.NonSslPort.md) | Azure Cache for Redis should only accept secure connections. | Critical
[Azure.Redis.PublicNetworkAccess](../rules/Azure.Redis.PublicNetworkAccess.md) | Redis cache should disable public network access. | Critical
[Azure.RedisEnterprise.MinTLS](../rules/Azure.RedisEnterprise.MinTLS.md) | Redis Cache should reject TLS versions older than 1.2. | Critical
[Azure.Resource.AllowedRegions](../rules/Azure.Resource.AllowedRegions.md) | Resources should be deployed to allowed regions. | Important
[Azure.RSV.Immutable](../rules/Azure.RSV.Immutable.md) | Ensure immutability is configured to protect backup data. | Important
[Azure.Search.ManagedIdentity](../rules/Azure.Search.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.ServiceBus.AuditLogs](../rules/Azure.ServiceBus.AuditLogs.md) | Ensure namespaces audit diagnostic logs are enabled. | Important
[Azure.ServiceBus.DisableLocalAuth](../rules/Azure.ServiceBus.DisableLocalAuth.md) | Authenticate Service Bus publishers and consumers with Entra ID identities. | Important
[Azure.ServiceBus.MinTLS](../rules/Azure.ServiceBus.MinTLS.md) | Service Bus namespaces should reject TLS versions older than 1.2. | Important
[Azure.ServiceFabric.AAD](../rules/Azure.ServiceFabric.AAD.md) | Use Azure Active Directory (AAD) client authentication for Service Fabric clusters. | Critical
[Azure.SignalR.ManagedIdentity](../rules/Azure.SignalR.ManagedIdentity.md) | Configure SignalR Services to use managed identities to access Azure resources securely. | Important
[Azure.SQL.AAD](../rules/Azure.SQL.AAD.md) | Use Entra ID authentication with Azure SQL databases. | Critical
[Azure.SQL.AADOnly](../rules/Azure.SQL.AADOnly.md) | Ensure Azure AD-only authentication is enabled with Azure SQL Database. | Important
[Azure.SQL.AllowAzureAccess](../rules/Azure.SQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.SQL.Auditing](../rules/Azure.SQL.Auditing.md) | Enable auditing for Azure SQL logical server. | Important
[Azure.SQL.DefenderCloud](../rules/Azure.SQL.DefenderCloud.md) | Enable Microsoft Defender for Azure SQL logical server. | Important
[Azure.SQL.FirewallIPRange](../rules/Azure.SQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses set in the allowed IP list (CIDR range). | Important
[Azure.SQL.FirewallRuleCount](../rules/Azure.SQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
[Azure.SQL.MinTLS](../rules/Azure.SQL.MinTLS.md) | Azure SQL Database servers should reject TLS versions older than 1.2. | Critical
[Azure.SQL.TDE](../rules/Azure.SQL.TDE.md) | Use Transparent Data Encryption (TDE) with Azure SQL Database. | Critical
[Azure.SQLMI.AAD](../rules/Azure.SQLMI.AAD.md) | Use Azure Active Directory (AAD) authentication with Azure SQL Managed Instance. | Critical
[Azure.SQLMI.AADOnly](../rules/Azure.SQLMI.AADOnly.md) | Ensure Azure AD-only authentication is enabled with Azure SQL Managed Instance. | Important
[Azure.SQLMI.ManagedIdentity](../rules/Azure.SQLMI.ManagedIdentity.md) | Ensure managed identity is used to allow support for Azure AD authentication. | Important
[Azure.Storage.BlobAccessType](../rules/Azure.Storage.BlobAccessType.md) | Use containers configured with a private access type that requires authorization. | Important
[Azure.Storage.BlobPublicAccess](../rules/Azure.Storage.BlobPublicAccess.md) | Storage Accounts should only accept authorized requests. | Important
[Azure.Storage.Defender.MalwareScan](../rules/Azure.Storage.Defender.MalwareScan.md) | Enable Malware Scanning in Microsoft Defender for Storage. | Critical
[Azure.Storage.DefenderCloud](../rules/Azure.Storage.DefenderCloud.md) | Enable Microsoft Defender for Storage for storage accounts. | Critical
[Azure.Storage.Firewall](../rules/Azure.Storage.Firewall.md) | Storage Accounts should only accept explicitly allowed traffic. | Important
[Azure.Storage.MinTLS](../rules/Azure.Storage.MinTLS.md) | Storage Accounts should reject TLS versions older than 1.2. | Critical
[Azure.Storage.SecureTransfer](../rules/Azure.Storage.SecureTransfer.md) | Storage accounts should only accept encrypted connections. | Important
[Azure.TrafficManager.Protocol](../rules/Azure.TrafficManager.Protocol.md) | Monitor Traffic Manager web-based endpoints with HTTPS. | Important
[Azure.VM.ADE](../rules/Azure.VM.ADE.md) | Use Azure Disk Encryption (ADE). | Important
[Azure.VM.PublicKey](../rules/Azure.VM.PublicKey.md) | Linux virtual machines should use public keys. | Important
[Azure.VM.ScriptExtensions](../rules/Azure.VM.ScriptExtensions.md) | Custom Script Extensions scripts that reference secret values must use the protectedSettings. | Important
[Azure.VM.Updates](../rules/Azure.VM.Updates.md) | Ensure automatic updates are enabled at deployment. | Important
[Azure.VM.UseManagedDisks](../rules/Azure.VM.UseManagedDisks.md) | Virtual machines (VMs) should use managed disks. | Important
[Azure.VMSS.PublicKey](../rules/Azure.VMSS.PublicKey.md) | Use SSH keys instead of common credentials to secure virtual machine scale sets against malicious activities. | Important
[Azure.VMSS.ScriptExtensions](../rules/Azure.VMSS.ScriptExtensions.md) | Custom Script Extensions scripts that reference secret values must use the protectedSettings. | Important
[Azure.VNET.FirewallSubnet](../rules/Azure.VNET.FirewallSubnet.md) | Use Azure Firewall to filter network traffic to and from Azure resources. | Important
[Azure.VNET.UseNSGs](../rules/Azure.VNET.UseNSGs.md) | Virtual network (VNET) subnets should have Network Security Groups (NSGs) assigned. | Critical
[Azure.WebPubSub.ManagedIdentity](../rules/Azure.WebPubSub.ManagedIdentity.md) | Configure Web PubSub Services to use managed identities to access Azure resources securely. | Important
