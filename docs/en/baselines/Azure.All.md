# Azure.All

Includes all Azure rules.

## Rules

The following rules are included within `Azure.All`. This baseline includes a total of 271 rules.

Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.AdminUser](../rules/Azure.ACR.AdminUser.md) | Use Azure AD identities instead of using the registry admin user. | Critical
[Azure.ACR.ContainerScan](../rules/Azure.ACR.ContainerScan.md) | Enable vulnerability scanning for container images. | Critical
[Azure.ACR.ContentTrust](../rules/Azure.ACR.ContentTrust.md) | Use container images signed by a trusted image publisher. | Important
[Azure.ACR.GeoReplica](../rules/Azure.ACR.GeoReplica.md) | Use geo-replicated container registries to compliment a multi-region container deployments. | Important
[Azure.ACR.ImageHealth](../rules/Azure.ACR.ImageHealth.md) | Remove container images with known vulnerabilities. | Critical
[Azure.ACR.MinSku](../rules/Azure.ACR.MinSku.md) | ACR should use the Premium or Standard SKU for production deployments. | Important
[Azure.ACR.Name](../rules/Azure.ACR.Name.md) | Container registry names should meet naming requirements. | Awareness
[Azure.ACR.Quarantine](../rules/Azure.ACR.Quarantine.md) | Enable container image quarantine, scan, and mark images as verified. | Important
[Azure.ACR.Retention](../rules/Azure.ACR.Retention.md) | Use a retention policy to cleanup untagged manifests. | Important
[Azure.ACR.Usage](../rules/Azure.ACR.Usage.md) | Regularly remove deprecated and unneeded images to reduce storage usage. | Important
[Azure.ADX.DiskEncryption](../rules/Azure.ADX.DiskEncryption.md) | Use disk encryption for Azure Data Explorer (ADX) clusters. | Important
[Azure.ADX.ManagedIdentity](../rules/Azure.ADX.ManagedIdentity.md) | Configure Data Explorer clusters to use managed identities to access Azure resources securely. | Important
[Azure.ADX.SLA](../rules/Azure.ADX.SLA.md) | Use SKUs that include a SLA when configuring Azure Data Explorer (ADX) clusters. | Important
[Azure.ADX.Usage](../rules/Azure.ADX.Usage.md) | Regularly remove unused resources to reduce costs. | Important
[Azure.AKS.AuditLogs](../rules/Azure.AKS.AuditLogs.md) | AKS clusters should collect security-based audit logs to assess and monitor the compliance status of workloads. | Important
[Azure.AKS.AuthorizedIPs](../rules/Azure.AKS.AuthorizedIPs.md) | Restrict access to API server endpoints to authorized IP addresses. | Important
[Azure.AKS.AutoScaling](../rules/Azure.AKS.AutoScaling.md) | Use Autoscaling to ensure AKS clusters deployed with virtual machine scale sets are running efficiently with the right number of nodes for the workloads present. | Important
[Azure.AKS.AutoUpgrade](../rules/Azure.AKS.AutoUpgrade.md) | Configure AKS to automatically upgrade to newer supported AKS versions as they are made available. | Important
[Azure.AKS.AvailabilityZone](../rules/Azure.AKS.AvailabilityZone.md) | AKS clusters deployed with virtual machine scale sets should use availability zones in supported regions for high availability. | Important
[Azure.AKS.AzurePolicyAddOn](../rules/Azure.AKS.AzurePolicyAddOn.md) | Configure Azure Kubernetes Service (AKS) clusters to use Azure Policy Add-on for Kubernetes. | Important
[Azure.AKS.AzureRBAC](../rules/Azure.AKS.AzureRBAC.md) | Use Azure RBAC for Kubernetes Authorization with AKS clusters. | Important
[Azure.AKS.CNISubnetSize](../rules/Azure.AKS.CNISubnetSize.md) | AKS clusters using Azure CNI should use large subnets to reduce IP exhaustion issues. | Important
[Azure.AKS.ContainerInsights](../rules/Azure.AKS.ContainerInsights.md) | Enable Container insights to monitor AKS cluster workloads. | Important
[Azure.AKS.DNSPrefix](../rules/Azure.AKS.DNSPrefix.md) | Azure Kubernetes Service (AKS) cluster DNS prefix should meet naming requirements. | Awareness
[Azure.AKS.HttpAppRouting](../rules/Azure.AKS.HttpAppRouting.md) | Disable HTTP application routing add-on in AKS clusters. | Important
[Azure.AKS.LocalAccounts](../rules/Azure.AKS.LocalAccounts.md) | Enforce named user accounts with RBAC assigned permissions. | Important
[Azure.AKS.ManagedAAD](../rules/Azure.AKS.ManagedAAD.md) | Use AKS-managed Azure AD to simplify authorization and improve security. | Important
[Azure.AKS.ManagedIdentity](../rules/Azure.AKS.ManagedIdentity.md) | Configure AKS clusters to use managed identities for managing cluster infrastructure. | Important
[Azure.AKS.MinNodeCount](../rules/Azure.AKS.MinNodeCount.md) | AKS clusters should have minimum number of nodes for failover and updates. | Important
[Azure.AKS.Name](../rules/Azure.AKS.Name.md) | Azure Kubernetes Service (AKS) cluster names should meet naming requirements. | Awareness
[Azure.AKS.NetworkPolicy](../rules/Azure.AKS.NetworkPolicy.md) | Deploy AKS clusters with Network Policies enabled. | Important
[Azure.AKS.NodeMinPods](../rules/Azure.AKS.NodeMinPods.md) | Azure Kubernetes Cluster (AKS) nodes should use a minimum number of pods. | Important
[Azure.AKS.PlatformLogs](../rules/Azure.AKS.PlatformLogs.md) | AKS clusters should collect platform diagnostic logs to monitor the state of workloads. | Important
[Azure.AKS.PodIdentity](../rules/Azure.AKS.PodIdentity.md) | Configure AKS clusters to use AAD pod identities to access Azure resources securely. | Important
[Azure.AKS.PoolScaleSet](../rules/Azure.AKS.PoolScaleSet.md) | Deploy AKS clusters with nodes pools based on VM scale sets. | Important
[Azure.AKS.PoolVersion](../rules/Azure.AKS.PoolVersion.md) | AKS node pools should match Kubernetes control plane version. | Important
[Azure.AKS.SecretStore](../rules/Azure.AKS.SecretStore.md) | Deploy AKS clusters with Secrets Store CSI Driver and store Secrets in Key Vayult. | Important
[Azure.AKS.SecretStoreRotation](../rules/Azure.AKS.SecretStoreRotation.md) | Enable autorotation of Secrets Store CSI Driver secrets for AKS clusters. | Important
[Azure.AKS.StandardLB](../rules/Azure.AKS.StandardLB.md) | Azure Kubernetes Clusters (AKS) should use a Standard load balancer SKU. | Important
[Azure.AKS.UseRBAC](../rules/Azure.AKS.UseRBAC.md) | Deploy AKS cluster with role-based access control (RBAC) enabled. | Important
[Azure.AKS.Version](../rules/Azure.AKS.Version.md) | AKS control plane and nodes pools should use a current stable release. | Important
[Azure.APIM.APIDescriptors](../rules/Azure.APIM.APIDescriptors.md) | API Management APIs should have a display name and description. | Awareness
[Azure.APIM.AvailabilityZone](../rules/Azure.APIM.AvailabilityZone.md) | API management services deployed with Premium SKU should use availability zones in supported regions for high availability. | Important
[Azure.APIM.CertificateExpiry](../rules/Azure.APIM.CertificateExpiry.md) | Renew certificates used for custom domain bindings. | Important
[Azure.APIM.Ciphers](../rules/Azure.APIM.Ciphers.md) | API Management should not accept weak or deprecated ciphers. | Important
[Azure.APIM.EncryptValues](../rules/Azure.APIM.EncryptValues.md) | API Management named values should be encrypted. | Important
[Azure.APIM.HTTPBackend](../rules/Azure.APIM.HTTPBackend.md) | Use HTTPS for communication to backend services. | Critical
[Azure.APIM.HTTPEndpoint](../rules/Azure.APIM.HTTPEndpoint.md) | Enforce HTTPS for communication to API clients. | Important
[Azure.APIM.ManagedIdentity](../rules/Azure.APIM.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.APIM.Name](../rules/Azure.APIM.Name.md) | API Management service names should meet naming requirements. | Awareness
[Azure.APIM.ProductApproval](../rules/Azure.APIM.ProductApproval.md) | Configure products to require approval. | Important
[Azure.APIM.ProductDescriptors](../rules/Azure.APIM.ProductDescriptors.md) | API Management products should have a display name and description. | Awareness
[Azure.APIM.ProductSubscription](../rules/Azure.APIM.ProductSubscription.md) | Configure products to require a subscription. | Important
[Azure.APIM.ProductTerms](../rules/Azure.APIM.ProductTerms.md) | Set legal terms for each product registered in API Management. | Important
[Azure.APIM.Protocols](../rules/Azure.APIM.Protocols.md) | API Management should only accept a minimum of TLS 1.2. | Important
[Azure.APIM.SampleProducts](../rules/Azure.APIM.SampleProducts.md) | Remove starter and unlimited sample products. | Awareness
[Azure.AppConfig.Name](../rules/Azure.AppConfig.Name.md) | App Configuration store names should meet naming requirements. | Awareness
[Azure.AppConfig.SKU](../rules/Azure.AppConfig.SKU.md) | App Configuration should use a minimum size of Standard. | Important
[Azure.AppGw.AvailabilityZone](../rules/Azure.AppGw.AvailabilityZone.md) | Application gateways deployed with V2 SKU(Standard_v2, WAF_v2) should use availability zones in supported regions for high availability. | Important
[Azure.AppGw.MinInstance](../rules/Azure.AppGw.MinInstance.md) | Application Gateways should use a minimum of two instances. | Important
[Azure.AppGw.MinSku](../rules/Azure.AppGw.MinSku.md) | Application Gateway should use a minimum instance size of Medium. | Important
[Azure.AppGw.OWASP](../rules/Azure.AppGw.OWASP.md) | Application Gateway Web Application Firewall (WAF) should use OWASP 3.x rules. | Important
[Azure.AppGw.Prevention](../rules/Azure.AppGw.Prevention.md) | Internet exposed Application Gateways should use prevention mode to protect backend resources. | Critical
[Azure.AppGw.SSLPolicy](../rules/Azure.AppGw.SSLPolicy.md) | Application Gateway should only accept a minimum of TLS 1.2. | Critical
[Azure.AppGw.UseHTTPS](../rules/Azure.AppGw.UseHTTPS.md) | Application Gateways should only expose frontend HTTP endpoints over HTTPS. | Critical
[Azure.AppGw.UseWAF](../rules/Azure.AppGw.UseWAF.md) | Internet accessible Application Gateways should use protect endpoints with WAF. | Critical
[Azure.AppGw.WAFEnabled](../rules/Azure.AppGw.WAFEnabled.md) | Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources. | Critical
[Azure.AppGw.WAFRules](../rules/Azure.AppGw.WAFRules.md) | Application Gateway Web Application Firewall (WAF) should have all rules enabled. | Important
[Azure.AppInsights.Name](../rules/Azure.AppInsights.Name.md) | Azure Application Insights resources names should meet naming requirements. | Awareness
[Azure.AppInsights.Workspace](../rules/Azure.AppInsights.Workspace.md) | Configure Application Insights resources to store data in workspaces. | Important
[Azure.AppService.AlwaysOn](../rules/Azure.AppService.AlwaysOn.md) | Configure Always On for App Service apps. | Important
[Azure.AppService.ARRAffinity](../rules/Azure.AppService.ARRAffinity.md) | Disable client affinity for stateless services. | Awareness
[Azure.AppService.HTTP2](../rules/Azure.AppService.HTTP2.md) | Use HTTP/2 instead of HTTP/1.x to improve protocol efficiency. | Awareness
[Azure.AppService.ManagedIdentity](../rules/Azure.AppService.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.AppService.MinPlan](../rules/Azure.AppService.MinPlan.md) | Use at least a Standard App Service Plan. | Important
[Azure.AppService.MinTLS](../rules/Azure.AppService.MinTLS.md) | App Service should reject TLS versions older then 1.2. | Critical
[Azure.AppService.NETVersion](../rules/Azure.AppService.NETVersion.md) | Configure applications to use newer .NET Framework versions. | Important
[Azure.AppService.PHPVersion](../rules/Azure.AppService.PHPVersion.md) | Configure applications to use newer PHP runtime versions. | Important
[Azure.AppService.PlanInstanceCount](../rules/Azure.AppService.PlanInstanceCount.md) | App Service Plan should use a minimum number of instances for failover. | Important
[Azure.AppService.RemoteDebug](../rules/Azure.AppService.RemoteDebug.md) | Disable remote debugging on App Service apps when not in use. | Important
[Azure.AppService.UseHTTPS](../rules/Azure.AppService.UseHTTPS.md) | Azure App Service apps should only accept encrypted connections. | Important
[Azure.ASG.Name](../rules/Azure.ASG.Name.md) | Application Security Group (ASG) names should meet naming requirements. | Awareness
[Azure.Automation.AuditLogs](../rules/Azure.Automation.AuditLogs.md) | Ensure automation account audit diagnostic logs are enabled. | Important
[Azure.Automation.EncryptVariables](../rules/Azure.Automation.EncryptVariables.md) | Azure Automation variables should be encrypted. | Important
[Azure.Automation.ManagedIdentity](../rules/Azure.Automation.ManagedIdentity.md) | Ensure managed identity is used for authentication. | Important
[Azure.Automation.PlatformLogs](../rules/Azure.Automation.PlatformLogs.md) | Ensure automation account platform diagnostic logs are enabled. | Important
[Azure.Automation.WebHookExpiry](../rules/Azure.Automation.WebHookExpiry.md) | Do not create webhooks with an expiry time greater than 1 year (default). | Awareness
[Azure.CDN.EndpointName](../rules/Azure.CDN.EndpointName.md) | Azure CDN Endpoint names should meet naming requirements. | Awareness
[Azure.CDN.HTTP](../rules/Azure.CDN.HTTP.md) | Enforce HTTPS for client connections. | Important
[Azure.CDN.MinTLS](../rules/Azure.CDN.MinTLS.md) | Azure CDN endpoints should reject TLS versions older than 1.2. | Important
[Azure.ContainerApp.Insecure](../rules/Azure.ContainerApp.Insecure.md) | Ensure insecure inbound traffic is not permitted to the container app. | Important
[Azure.Cosmos.AccountName](../rules/Azure.Cosmos.AccountName.md) | Cosmos DB account names should meet naming requirements. | Awareness
[Azure.Cosmos.DisableMetadataWrite](../rules/Azure.Cosmos.DisableMetadataWrite.md) | Use Azure AD identities for management place operations in Azure Cosmos DB. | Important
[Azure.DataFactory.Version](../rules/Azure.DataFactory.Version.md) | Consider migrating to DataFactory v2. | Awareness
[Azure.EventGrid.DisableLocalAuth](../rules/Azure.EventGrid.DisableLocalAuth.md) | Authenticate publishing clients with Azure AD identities. | Important
[Azure.EventGrid.ManagedIdentity](../rules/Azure.EventGrid.ManagedIdentity.md) | Use managed identities to deliver Event Grid Topic events. | Important
[Azure.EventGrid.TopicPublicAccess](../rules/Azure.EventGrid.TopicPublicAccess.md) | Use Private Endpoints to access Event Grid topics and domains. | Important
[Azure.EventHub.DisableLocalAuth](../rules/Azure.EventHub.DisableLocalAuth.md) | Authenticate Event Hub publishers and consumers with Azure AD identities. | Important
[Azure.EventHub.Usage](../rules/Azure.EventHub.Usage.md) | Regularly remove unused resources to reduce costs. | Important
[Azure.Firewall.Mode](../rules/Azure.Firewall.Mode.md) | Deny high confidence malicious IP addresses and domains. | Critical
[Azure.Firewall.Name](../rules/Azure.Firewall.Name.md) | Firewall names should meet naming requirements. | Awareness
[Azure.Firewall.PolicyName](../rules/Azure.Firewall.PolicyName.md) | Firewall policy names should meet naming requirements. | Awareness
[Azure.FrontDoor.Logs](../rules/Azure.FrontDoor.Logs.md) | Audit and monitor access through Front Door. | Important
[Azure.FrontDoor.MinTLS](../rules/Azure.FrontDoor.MinTLS.md) | Front Door should reject TLS versions older then 1.2. | Critical
[Azure.FrontDoor.Name](../rules/Azure.FrontDoor.Name.md) | Front Door names should meet naming requirements. | Awareness
[Azure.FrontDoor.Probe](../rules/Azure.FrontDoor.Probe.md) | Configure and enable health probes for each backend pool. | Important
[Azure.FrontDoor.ProbeMethod](../rules/Azure.FrontDoor.ProbeMethod.md) | Configure health probes to use HEAD instead of GET requests. | Important
[Azure.FrontDoor.ProbePath](../rules/Azure.FrontDoor.ProbePath.md) | Configure a dedicated path for health probe requests. | Important
[Azure.FrontDoor.State](../rules/Azure.FrontDoor.State.md) | Enable Azure Front Door instance. | Awareness
[Azure.FrontDoor.UseWAF](../rules/Azure.FrontDoor.UseWAF.md) | Enable Web Application Firewall (WAF) policies on each Front Door endpoint. | Critical
[Azure.FrontDoor.WAF.Enabled](../rules/Azure.FrontDoor.WAF.Enabled.md) | Front Door Web Application Firewall (WAF) policy must be enabled to protect back end resources. | Critical
[Azure.FrontDoor.WAF.Mode](../rules/Azure.FrontDoor.WAF.Mode.md) | Use protection mode in Front Door Web Application Firewall (WAF) policies to protect back end resources. | Critical
[Azure.FrontDoor.WAF.Name](../rules/Azure.FrontDoor.WAF.Name.md) | Front Door WAF policy names should meet naming requirements. | Awareness
[Azure.Identity.UserAssignedName](../rules/Azure.Identity.UserAssignedName.md) | Managed Identity names should meet naming requirements. | Awareness
[Azure.KeyVault.AccessPolicy](../rules/Azure.KeyVault.AccessPolicy.md) | Use the principal of least privilege when assigning access to Key Vault. | Important
[Azure.KeyVault.AutoRotationPolicy](../rules/Azure.KeyVault.AutoRotationPolicy.md) | Key Vault keys should have auto-rotation enabled. | Important
[Azure.KeyVault.KeyName](../rules/Azure.KeyVault.KeyName.md) | Key Vault Key names should meet naming requirements. | Awareness
[Azure.KeyVault.Logs](../rules/Azure.KeyVault.Logs.md) | Audit and monitor access to Key Vault data. | Important
[Azure.KeyVault.Name](../rules/Azure.KeyVault.Name.md) | Key Vault names should meet naming requirements. | Awareness
[Azure.KeyVault.PurgeProtect](../rules/Azure.KeyVault.PurgeProtect.md) | Enable Purge Protection on Key Vaults to prevent early purge of vaults and vault items. | Important
[Azure.KeyVault.SecretName](../rules/Azure.KeyVault.SecretName.md) | Key Vault Secret names should meet naming requirements. | Awareness
[Azure.KeyVault.SoftDelete](../rules/Azure.KeyVault.SoftDelete.md) | Enable Soft Delete on Key Vaults to protect vaults and vault items from accidental deletion. | Important
[Azure.LB.AvailabilityZone](../rules/Azure.LB.AvailabilityZone.md) | Load balancers deployed with Standard SKU should be zone-redundant for high availability. | Important
[Azure.LB.Name](../rules/Azure.LB.Name.md) | Load Balancer names should meet naming requirements. | Awareness
[Azure.LB.Probe](../rules/Azure.LB.Probe.md) | Use a specific probe for web protocols. | Important
[Azure.LB.StandardSKU](../rules/Azure.LB.StandardSKU.md) | Load balancers should be deployed with Standard SKU for production workloads. | Important
[Azure.LogicApp.LimitHTTPTrigger](../rules/Azure.LogicApp.LimitHTTPTrigger.md) | Limit HTTP request trigger access to trusted IP addresses. | Critical
[Azure.Monitor.ServiceHealth](../rules/Azure.Monitor.ServiceHealth.md) | Configure Service Health alerts to notify administrators. | Important
[Azure.MySQL.AllowAzureAccess](../rules/Azure.MySQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.MySQL.FirewallIPRange](../rules/Azure.MySQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important
[Azure.MySQL.FirewallRuleCount](../rules/Azure.MySQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
[Azure.MySQL.MinTLS](../rules/Azure.MySQL.MinTLS.md) | MySQL DB servers should reject TLS versions older than 1.2. | Critical
[Azure.MySQL.ServerName](../rules/Azure.MySQL.ServerName.md) | Azure MySQL DB server names should meet naming requirements. | Awareness
[Azure.MySQL.UseSSL](../rules/Azure.MySQL.UseSSL.md) | Enforce encrypted MySQL connections. | Critical
[Azure.NSG.AnyInboundSource](../rules/Azure.NSG.AnyInboundSource.md) | Network security groups (NSGs) should avoid rules that allow any inbound source. | Critical
[Azure.NSG.Associated](../rules/Azure.NSG.Associated.md) | Network Security Groups (NSGs) should be associated to a subnet or network interface. | Awareness
[Azure.NSG.DenyAllInbound](../rules/Azure.NSG.DenyAllInbound.md) | Avoid denying all inbound traffic. | Important
[Azure.NSG.LateralTraversal](../rules/Azure.NSG.LateralTraversal.md) | Deny outbound management connections from non-management hosts. | Important
[Azure.NSG.Name](../rules/Azure.NSG.Name.md) | Network Security Group (NSG) names should meet naming requirements. | Awareness
[Azure.Policy.AssignmentAssignedBy](../rules/Azure.Policy.AssignmentAssignedBy.md) | Policy assignments should use assignedBy metadata. | Awareness
[Azure.Policy.AssignmentDescriptors](../rules/Azure.Policy.AssignmentDescriptors.md) | Policy assignments should use a display name and description. | Awareness
[Azure.Policy.Descriptors](../rules/Azure.Policy.Descriptors.md) | Policy and initiative definitions should use a display name, description, and category. | Awareness
[Azure.Policy.ExemptionDescriptors](../rules/Azure.Policy.ExemptionDescriptors.md) | Policy exemptions should use a display name and description. | Awareness
[Azure.Policy.WaiverExpiry](../rules/Azure.Policy.WaiverExpiry.md) | Configure policy waiver exemptions to expire. | Awareness
[Azure.PostgreSQL.AllowAzureAccess](../rules/Azure.PostgreSQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.PostgreSQL.FirewallIPRange](../rules/Azure.PostgreSQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important
[Azure.PostgreSQL.FirewallRuleCount](../rules/Azure.PostgreSQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
[Azure.PostgreSQL.MinTLS](../rules/Azure.PostgreSQL.MinTLS.md) | PostgreSQL DB servers should reject TLS versions older than 1.2. | Critical
[Azure.PostgreSQL.ServerName](../rules/Azure.PostgreSQL.ServerName.md) | Azure PostgreSQL DB server names should meet naming requirements. | Awareness
[Azure.PostgreSQL.UseSSL](../rules/Azure.PostgreSQL.UseSSL.md) | Enforce encrypted PostgreSQL connections. | Critical
[Azure.PrivateEndpoint.Name](../rules/Azure.PrivateEndpoint.Name.md) | Private Endpoint names should meet naming requirements. | Awareness
[Azure.PublicIP.AvailabilityZone](../rules/Azure.PublicIP.AvailabilityZone.md) | Public IP addresses deployed with Standard SKU should use availability zones in supported regions for high availability. | Important
[Azure.PublicIP.DNSLabel](../rules/Azure.PublicIP.DNSLabel.md) | Public IP domain name labels should meet naming requirements. | Awareness
[Azure.PublicIP.IsAttached](../rules/Azure.PublicIP.IsAttached.md) | Public IP address should be attached or removed. | Important
[Azure.PublicIP.Name](../rules/Azure.PublicIP.Name.md) | Public IP names should meet naming requirements. | Awareness
[Azure.PublicIP.StandardSKU](../rules/Azure.PublicIP.StandardSKU.md) | Public IP addresses should be deployed with Standard SKU for production workloads. | Important
[Azure.RBAC.CoAdministrator](../rules/Azure.RBAC.CoAdministrator.md) | Delegate access to manage Azure resources using role-based access control (RBAC). | Important
[Azure.RBAC.LimitMGDelegation](../rules/Azure.RBAC.LimitMGDelegation.md) | Limit Role-Base Access Control (RBAC) inheritance from Management Groups. | Important
[Azure.RBAC.LimitOwner](../rules/Azure.RBAC.LimitOwner.md) | Limit the number of subscription Owners. | Important
[Azure.RBAC.PIM](../rules/Azure.RBAC.PIM.md) | Use just-in-time (JiT) activation of roles instead of persistent role assignment. | Important
[Azure.RBAC.UseGroups](../rules/Azure.RBAC.UseGroups.md) | Use groups for assigning permissions instead of individual user accounts. | Important
[Azure.RBAC.UseRGDelegation](../rules/Azure.RBAC.UseRGDelegation.md) | Use RBAC assignments on resource groups instead of individual resources. | Important
[Azure.Redis.AvailabilityZone](../rules/Azure.Redis.AvailabilityZone.md) | Premium Redis cache should be deployed with availability zones for high availability. | Important
[Azure.Redis.MaxMemoryReserved](../rules/Azure.Redis.MaxMemoryReserved.md) | Configure maxmemory-reserved to reserve memory for non-cache operations. | Important
[Azure.Redis.MinSKU](../rules/Azure.Redis.MinSKU.md) | Use Azure Cache for Redis instances of at least Standard C1. | Important
[Azure.Redis.MinTLS](../rules/Azure.Redis.MinTLS.md) | Redis Cache should reject TLS versions older then 1.2. | Critical
[Azure.Redis.NonSslPort](../rules/Azure.Redis.NonSslPort.md) | Azure Cache for Redis should only accept secure connections. | Critical
[Azure.Redis.PublicNetworkAccess](../rules/Azure.Redis.PublicNetworkAccess.md) | Redis cache should disable public network access. | Critical
[Azure.RedisEnterprise.Zones](../rules/Azure.RedisEnterprise.Zones.md) | Enterprise Redis cache should be zone-redundant for high availability. | Important
[Azure.Resource.AllowedRegions](../rules/Azure.Resource.AllowedRegions.md) | Resources should be deployed to allowed regions. | Awareness
[Azure.Resource.UseTags](../rules/Azure.Resource.UseTags.md) | Azure resources should be tagged using a standard convention. | Awareness
[Azure.ResourceGroup.Name](../rules/Azure.ResourceGroup.Name.md) | Resource Group names should meet naming requirements. | Awareness
[Azure.Route.Name](../rules/Azure.Route.Name.md) | Route table names should meet naming requirements. | Awareness
[Azure.RSV.ReplicationAlert](../rules/Azure.RSV.ReplicationAlert.md) | Recovery Services Vaults (RSV) without replication alerts configured may be at risk. | Important
[Azure.RSV.StorageType](../rules/Azure.RSV.StorageType.md) | Recovery Services Vaults (RSV) not using geo-replicated storage (GRS) may be at risk. | Important
[Azure.Search.IndexSLA](../rules/Azure.Search.IndexSLA.md) | Use a minimum of 3 replicas to receive an SLA for query and index updates. | Important
[Azure.Search.ManagedIdentity](../rules/Azure.Search.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.Search.Name](../rules/Azure.Search.Name.md) | Azure Cognitive Search service names should meet naming requirements. | Awareness
[Azure.Search.QuerySLA](../rules/Azure.Search.QuerySLA.md) | Use a minimum of 2 replicas to receive an SLA for index queries. | Important
[Azure.Search.SKU](../rules/Azure.Search.SKU.md) | Use the basic and standard tiers for entry level workloads. | Critical
[Azure.SecurityCenter.Contact](../rules/Azure.SecurityCenter.Contact.md) | Security Center email and phone contact details should be set. | Important
[Azure.SecurityCenter.Provisioning](../rules/Azure.SecurityCenter.Provisioning.md) | Enable auto-provisioning on to improve Azure Security Center insights. | Important
[Azure.ServiceBus.DisableLocalAuth](../rules/Azure.ServiceBus.DisableLocalAuth.md) | Authenticate Service Bus publishers and consumers with Azure AD identities. | Important
[Azure.ServiceBus.Usage](../rules/Azure.ServiceBus.Usage.md) | Regularly remove unused resources to reduce costs. | Important
[Azure.ServiceFabric.AAD](../rules/Azure.ServiceFabric.AAD.md) | Use Azure Active Directory (AAD) client authentication for Service Fabric clusters. | Critical
[Azure.SignalR.Name](../rules/Azure.SignalR.Name.md) | SignalR service instance names should meet naming requirements. | Awareness
[Azure.SQL.AAD](../rules/Azure.SQL.AAD.md) | Use Azure Active Directory (AAD) authentication with Azure SQL databases. | Critical
[Azure.SQL.AllowAzureAccess](../rules/Azure.SQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.SQL.Auditing](../rules/Azure.SQL.Auditing.md) | Enable auditing for Azure SQL logical server. | Important
[Azure.SQL.DBName](../rules/Azure.SQL.DBName.md) | Azure SQL Database names should meet naming requirements. | Awareness
[Azure.SQL.FGName](../rules/Azure.SQL.FGName.md) | Azure SQL failover group names should meet naming requirements. | Awareness
[Azure.SQL.FirewallIPRange](../rules/Azure.SQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important
[Azure.SQL.FirewallRuleCount](../rules/Azure.SQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
[Azure.SQL.MinTLS](../rules/Azure.SQL.MinTLS.md) | Azure SQL Database servers should reject TLS versions older than 1.2. | Critical
[Azure.SQL.ServerName](../rules/Azure.SQL.ServerName.md) | Azure SQL logical server names should meet naming requirements. | Awareness
[Azure.SQL.TDE](../rules/Azure.SQL.TDE.md) | Use Transparent Data Encryption (TDE) with Azure SQL Database. | Critical
[Azure.SQL.ThreatDetection](../rules/Azure.SQL.ThreatDetection.md) | Enable Advanced Thread Protection for Azure SQL logical server. | Important
[Azure.SQLMI.Name](../rules/Azure.SQLMI.Name.md) | SQL Managed Instance names should meet naming requirements. | Awareness
[Azure.Storage.BlobAccessType](../rules/Azure.Storage.BlobAccessType.md) | Use containers configured with a private access type that requires authorization. | Important
[Azure.Storage.BlobPublicAccess](../rules/Azure.Storage.BlobPublicAccess.md) | Storage Accounts should only accept authorized requests. | Important
[Azure.Storage.Firewall](../rules/Azure.Storage.Firewall.md) | Storage Accounts should only accept explicitly allowed traffic. | Important
[Azure.Storage.MinTLS](../rules/Azure.Storage.MinTLS.md) | Storage Accounts should reject TLS versions older than 1.2. | Critical
[Azure.Storage.Name](../rules/Azure.Storage.Name.md) | Storage Account names should meet naming requirements. | Awareness
[Azure.Storage.SecureTransfer](../rules/Azure.Storage.SecureTransfer.md) | Storage accounts should only accept encrypted connections. | Important
[Azure.Storage.SoftDelete](../rules/Azure.Storage.SoftDelete.md) | Enable blob soft delete on Storage Accounts. | Important
[Azure.Storage.UseReplication](../rules/Azure.Storage.UseReplication.md) | Storage Accounts not using geo-replicated storage (GRS) may be at risk. | Important
[Azure.Template.DebugDeployment](../rules/Azure.Template.DebugDeployment.md) | Use default deployment detail level for nested deployments. | Awareness
[Azure.Template.DefineParameters](../rules/Azure.Template.DefineParameters.md) | Each Azure Resource Manager (ARM) template file should contain a minimal number of parameters. | Awareness
[Azure.Template.ExpressionLength](../rules/Azure.Template.ExpressionLength.md) | Template expressions should not exceed the maximum length. | Awareness
[Azure.Template.LocationDefault](../rules/Azure.Template.LocationDefault.md) | Set the default value for the location parameter within an ARM template to resource group location. | Awareness
[Azure.Template.LocationType](../rules/Azure.Template.LocationType.md) | Location parameters should use a string value. | Important
[Azure.Template.MetadataLink](../rules/Azure.Template.MetadataLink.md) | Configure a metadata link for each parameter file. | Important
[Azure.Template.ParameterDataTypes](../rules/Azure.Template.ParameterDataTypes.md) | Set the parameter default value to a value of the same type. | Important
[Azure.Template.ParameterFile](../rules/Azure.Template.ParameterFile.md) | Use ARM template parameter files that are valid. | Important
[Azure.Template.ParameterMetadata](../rules/Azure.Template.ParameterMetadata.md) | Set metadata descriptions in Azure Resource Manager (ARM) template for each parameter. | Awareness
[Azure.Template.ParameterMinMaxValue](../rules/Azure.Template.ParameterMinMaxValue.md) | Template parameters minValue and maxValue constraints must be valid. | Important
[Azure.Template.ParameterScheme](../rules/Azure.Template.ParameterScheme.md) | Use an Azure template parameter file schema with the https scheme. | Awareness
[Azure.Template.ParameterStrongType](../rules/Azure.Template.ParameterStrongType.md) | Set the parameter value to a value that matches the specified strong type. | Awareness
[Azure.Template.ParameterValue](../rules/Azure.Template.ParameterValue.md) | Specify a value for each parameter in template parameter files. | Awareness
[Azure.Template.ResourceLocation](../rules/Azure.Template.ResourceLocation.md) | Template resource location should be an expression or global. | Awareness
[Azure.Template.Resources](../rules/Azure.Template.Resources.md) | Each Azure Resource Manager (ARM) template file should deploy at least one resource. | Awareness
[Azure.Template.TemplateFile](../rules/Azure.Template.TemplateFile.md) | Use ARM template files that are valid. | Important
[Azure.Template.TemplateSchema](../rules/Azure.Template.TemplateSchema.md) | Use a more recent version of the Azure template schema. | Awareness
[Azure.Template.TemplateScheme](../rules/Azure.Template.TemplateScheme.md) | Use an Azure template file schema with the https scheme. | Awareness
[Azure.Template.UseComments](../rules/Azure.Template.UseComments.md) | Use comments for each resource in ARM template to communicate purpose. | Awareness
[Azure.Template.UseDescriptions](../rules/Azure.Template.UseDescriptions.md) | Use descriptions for each resource in generated template(bicep, psarm, AzOps) to communicate purpose. | Awareness
[Azure.Template.UseLocationParameter](../rules/Azure.Template.UseLocationParameter.md) | Template should reference a location parameter to specify resource location. | Awareness
[Azure.Template.UseParameters](../rules/Azure.Template.UseParameters.md) | Each Azure Resource Manager (ARM) template parameter should be used or removed from template files. | Awareness
[Azure.Template.UseVariables](../rules/Azure.Template.UseVariables.md) | Each Azure Resource Manager (ARM) template variable should be used or removed from template files. | Awareness
[Azure.Template.ValidSecretRef](../rules/Azure.Template.ValidSecretRef.md) | Use a valid secret reference within parameter files. | Awareness
[Azure.TrafficManager.Endpoints](../rules/Azure.TrafficManager.Endpoints.md) | Traffic Manager should use at lest two enabled endpoints. | Important
[Azure.TrafficManager.Protocol](../rules/Azure.TrafficManager.Protocol.md) | Monitor Traffic Manager web-based endpoints with HTTPS. | Important
[Azure.VM.AcceleratedNetworking](../rules/Azure.VM.AcceleratedNetworking.md) | Use accelerated networking for supported operating systems and VM types. | Important
[Azure.VM.ADE](../rules/Azure.VM.ADE.md) | Use Azure Disk Encryption (ADE). | Important
[Azure.VM.Agent](../rules/Azure.VM.Agent.md) | Ensure the VM agent is provisioned automatically. | Important
[Azure.VM.ASAlignment](../rules/Azure.VM.ASAlignment.md) | Use availability sets aligned with managed disks fault domains. | Important
[Azure.VM.ASMinMembers](../rules/Azure.VM.ASMinMembers.md) | Availability sets should be deployed with at least two virtual machines (VMs). | Important
[Azure.VM.ASName](../rules/Azure.VM.ASName.md) | Availability Set names should meet naming requirements. | Awareness
[Azure.VM.BasicSku](../rules/Azure.VM.BasicSku.md) | Virtual machines (VMs) should not use Basic sizes. | Important
[Azure.VM.ComputerName](../rules/Azure.VM.ComputerName.md) | Virtual Machine (VM) computer name should meet naming requirements. | Awareness
[Azure.VM.DiskAttached](../rules/Azure.VM.DiskAttached.md) | Managed disks should be attached to virtual machines or removed. | Important
[Azure.VM.DiskCaching](../rules/Azure.VM.DiskCaching.md) | Check disk caching is configured correctly for the workload. | Important
[Azure.VM.DiskName](../rules/Azure.VM.DiskName.md) | Managed Disk names should meet naming requirements. | Awareness
[Azure.VM.DiskSizeAlignment](../rules/Azure.VM.DiskSizeAlignment.md) | Align to the Managed Disk billing model to improve cost efficiency. | Awareness
[Azure.VM.Name](../rules/Azure.VM.Name.md) | Virtual Machine (VM) names should meet naming requirements. | Awareness
[Azure.VM.NICAttached](../rules/Azure.VM.NICAttached.md) | Network interfaces (NICs) should be attached. | Awareness
[Azure.VM.NICName](../rules/Azure.VM.NICName.md) | Network Interface (NIC) names should meet naming requirements. | Awareness
[Azure.VM.PPGName](../rules/Azure.VM.PPGName.md) | Proximity Placement Group (PPG) names should meet naming requirements. | Awareness
[Azure.VM.PromoSku](../rules/Azure.VM.PromoSku.md) | Virtual machines (VMs) should not use expired promotional SKU. | Awareness
[Azure.VM.PublicKey](../rules/Azure.VM.PublicKey.md) | Linux virtual machines should use public keys. | Important
[Azure.VM.Standalone](../rules/Azure.VM.Standalone.md) | VMs must use premium disks or use availability sets/ zones to meet SLA requirements. | Important
[Azure.VM.UniqueDns](../rules/Azure.VM.UniqueDns.md) | Network interfaces (NICs) should inherit DNS from virtual networks. | Awareness
[Azure.VM.Updates](../rules/Azure.VM.Updates.md) | Ensure automatic updates are enabled at deployment. | Important
[Azure.VM.UseHybridUseBenefit](../rules/Azure.VM.UseHybridUseBenefit.md) | Use Azure Hybrid Benefit for applicable virtual machine (VM) workloads. | Awareness
[Azure.VM.UseManagedDisks](../rules/Azure.VM.UseManagedDisks.md) | Virtual machines (VMs) should use managed disks. | Important
[Azure.VMSS.ComputerName](../rules/Azure.VMSS.ComputerName.md) | Virtual Machine Scale Set (VMSS) computer name should meet naming requirements. | Awareness
[Azure.VMSS.Name](../rules/Azure.VMSS.Name.md) | Virtual Machine Scale Set (VMSS) names should meet naming requirements. | Awareness
[Azure.VNET.LocalDNS](../rules/Azure.VNET.LocalDNS.md) | Virtual networks (VNETs) should use Azure local DNS servers. | Important
[Azure.VNET.Name](../rules/Azure.VNET.Name.md) | Virtual Network (VNET) names should meet naming requirements. | Awareness
[Azure.VNET.PeerState](../rules/Azure.VNET.PeerState.md) | VNET peering connections must be connected. | Important
[Azure.VNET.SingleDNS](../rules/Azure.VNET.SingleDNS.md) | VNETs should have at least two DNS servers assigned. | Important
[Azure.VNET.SubnetName](../rules/Azure.VNET.SubnetName.md) | Subnet names should meet naming requirements. | Awareness
[Azure.VNET.UseNSGs](../rules/Azure.VNET.UseNSGs.md) | Virtual network (VNET) subnets should have Network Security Groups (NSGs) assigned. | Critical
[Azure.VNG.ConnectionName](../rules/Azure.VNG.ConnectionName.md) | Virtual Network Gateway (VNG) connection names should meet naming requirements. | Awareness
[Azure.VNG.ERAvailabilityZoneSKU](../rules/Azure.VNG.ERAvailabilityZoneSKU.md) | Use availability zone SKU for virtual network gateways deployed with ExpressRoute gateway type. | Important
[Azure.VNG.ERLegacySKU](../rules/Azure.VNG.ERLegacySKU.md) | Migrate from legacy SKUs to improve reliability and performance of ExpressRoute (ER) gateways. | Important
[Azure.VNG.Name](../rules/Azure.VNG.Name.md) | Virtual Network Gateway (VNG) names should meet naming requirements. | Awareness
[Azure.VNG.VPNActiveActive](../rules/Azure.VNG.VPNActiveActive.md) | Use VPN gateways configured to operate in an Active-Active configuration to reduce connectivity downtime. | Important
[Azure.VNG.VPNAvailabilityZoneSKU](../rules/Azure.VNG.VPNAvailabilityZoneSKU.md) | Use availability zone SKU for virtual network gateways deployed with VPN gateway type. | Important
[Azure.VNG.VPNLegacySKU](../rules/Azure.VNG.VPNLegacySKU.md) | Migrate from legacy SKUs to improve reliability and performance of VPN gateways. | Important
[Azure.vWAN.Name](../rules/Azure.vWAN.Name.md) | Virtual WAN (vWAN) names should meet naming requirements. | Awareness
