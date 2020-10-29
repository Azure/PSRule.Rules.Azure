# Azure.Preview

Includes Azure features in preview.

## Rules

The following rules are included within `Azure.Preview`. This baseline includes a total of 175 rules.

Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.AdminUser](Azure.ACR.AdminUser.md) | Use Azure AD identities instead of using the registry admin user. | Critical
[Azure.ACR.ContainerScan](Azure.ACR.ContainerScan.md) | Enable vulnerability scanning for container images. | Critical
[Azure.ACR.ContentTrust](Azure.ACR.ContentTrust.md) | Use container images signed by a trusted image publisher. | Important
[Azure.ACR.GeoReplica](Azure.ACR.GeoReplica.md) | Use geo-replicated container registries to compliment a multi-region container deployments. | Important
[Azure.ACR.ImageHealth](Azure.ACR.ImageHealth.md) | Remove container images with known vulnerabilities. | Critical
[Azure.ACR.MinSku](Azure.ACR.MinSku.md) | ACR should use the Premium or Standard SKU for production deployments. | Important
[Azure.ACR.Name](Azure.ACR.Name.md) | Container registry names should meet naming requirements. | Awareness
[Azure.ACR.Quarantine](Azure.ACR.Quarantine.md) | Enable container image quarantine, scan, and mark images as verified. | Important
[Azure.ACR.Retention](Azure.ACR.Retention.md) | Use a retention policy to cleanup untagged manifests. | Important
[Azure.ACR.Usage](Azure.ACR.Usage.md) | Regularly remove deprecated and unneeded images to reduce storage usage. | Important
[Azure.AKS.AzurePolicyAddOn](Azure.AKS.AzurePolicyAddOn.md) | Configure Azure Kubernetes Service (AKS) clusters to use Azure Policy Add-on for Kubernetes. | Important
[Azure.AKS.DNSPrefix](Azure.AKS.DNSPrefix.md) | Azure Kubernetes Service (AKS) cluster DNS prefix should meet naming requirements. | Awareness
[Azure.AKS.ManagedIdentity](Azure.AKS.ManagedIdentity.md) | Configure AKS clusters to use managed identities for managing cluster infrastructure. | Important
[Azure.AKS.MinNodeCount](Azure.AKS.MinNodeCount.md) | AKS clusters should have minimum number of nodes for failover and updates. | Important
[Azure.AKS.Name](Azure.AKS.Name.md) | Azure Kubernetes Service (AKS) cluster names should meet naming requirements. | Awareness
[Azure.AKS.NetworkPolicy](Azure.AKS.NetworkPolicy.md) | Deploy AKS clusters with Azure Network Policies enabled. | Important
[Azure.AKS.NodeMinPods](Azure.AKS.NodeMinPods.md) | Azure Kubernetes Cluster (AKS) nodes should use a minimum number of pods. | Important
[Azure.AKS.PoolScaleSet](Azure.AKS.PoolScaleSet.md) | Deploy AKS clusters with nodes pools based on VM scale sets. | Important
[Azure.AKS.PoolVersion](Azure.AKS.PoolVersion.md) | AKS node pools should match Kubernetes control plane version. | Important
[Azure.AKS.StandardLB](Azure.AKS.StandardLB.md) | Azure Kubernetes Clusters (AKS) should use a Standard load balancer SKU. | Important
[Azure.AKS.UseRBAC](Azure.AKS.UseRBAC.md) | Deploy AKS cluster with role-based access control (RBAC) enabled. | Important
[Azure.AKS.Version](Azure.AKS.Version.md) | AKS control plane and nodes pools should use a current stable release. | Important
[Azure.APIM.APIDescriptors](Azure.APIM.APIDescriptors.md) | API Management APIs should have a display name and description. | Awareness
[Azure.APIM.CertificateExpiry](Azure.APIM.CertificateExpiry.md) | Renew certificates used for custom domain bindings. | Important
[Azure.APIM.EncryptValues](Azure.APIM.EncryptValues.md) | API Management named values should be encrypted. | Important
[Azure.APIM.HTTPBackend](Azure.APIM.HTTPBackend.md) | Use HTTPS for communication to backend services. | Critical
[Azure.APIM.HTTPEndpoint](Azure.APIM.HTTPEndpoint.md) | Enforce HTTPS for communication to API clients. | Important
[Azure.APIM.ManagedIdentity](Azure.APIM.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.APIM.Name](Azure.APIM.Name.md) | API Management service names should meet naming requirements. | Awareness
[Azure.APIM.ProductApproval](Azure.APIM.ProductApproval.md) | Configure products to require approval. | Important
[Azure.APIM.ProductDescriptors](Azure.APIM.ProductDescriptors.md) | API Management products should have a display name and description. | Awareness
[Azure.APIM.ProductSubscription](Azure.APIM.ProductSubscription.md) | Configure products to require a subscription. | Important
[Azure.APIM.ProductTerms](Azure.APIM.ProductTerms.md) | Set legal terms for each product registered in API Management. | Important
[Azure.APIM.Protocols](Azure.APIM.Protocols.md) | API Management should only accept a minimum of TLS 1.2. | Important
[Azure.APIM.SampleProducts](Azure.APIM.SampleProducts.md) | Remove starter and unlimited sample products. | Awareness
[Azure.AppConfig.Name](Azure.AppConfig.Name.md) | App Configuration store names should meet naming requirements. | Awareness
[Azure.AppConfig.SKU](Azure.AppConfig.SKU.md) | App Configuration should use a minimum size of Standard. | Important
[Azure.AppGw.MinInstance](Azure.AppGw.MinInstance.md) | Application Gateways should use a minimum of two instances. | Important
[Azure.AppGw.MinSku](Azure.AppGw.MinSku.md) | Application Gateway should use a minimum instance size of Medium. | Important
[Azure.AppGw.OWASP](Azure.AppGw.OWASP.md) | Application Gateway Web Application Firewall (WAF) should use OWASP 3.x rules. | Important
[Azure.AppGw.Prevention](Azure.AppGw.Prevention.md) | Internet exposed Application Gateways should use prevention mode to protect backend resources. | Critical
[Azure.AppGw.SSLPolicy](Azure.AppGw.SSLPolicy.md) | Application Gateway should only accept a minimum of TLS 1.2. | Critical
[Azure.AppGw.UseWAF](Azure.AppGw.UseWAF.md) | Internet accessible Application Gateways should use WAF. | Critical
[Azure.AppGw.WAFEnabled](Azure.AppGw.WAFEnabled.md) | Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources. | Critical
[Azure.AppGw.WAFRules](Azure.AppGw.WAFRules.md) | Application Gateway Web Application Firewall (WAF) should have all rules enabled. | Important
[Azure.AppService.AlwaysOn](Azure.AppService.AlwaysOn.md) | Configure Always On for App Service apps. | Important
[Azure.AppService.ARRAffinity](Azure.AppService.ARRAffinity.md) | Disable client affinity for stateless services. | Awareness
[Azure.AppService.HTTP2](Azure.AppService.HTTP2.md) | Use HTTP/2 instead of HTTP/1.x to improve protocol efficiency. | Awareness
[Azure.AppService.ManagedIdentity](Azure.AppService.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important
[Azure.AppService.MinPlan](Azure.AppService.MinPlan.md) | Use at least a Standard App Service Plan. | Important
[Azure.AppService.MinTLS](Azure.AppService.MinTLS.md) | App Service should reject TLS versions older then 1.2. | Critical
[Azure.AppService.NETVersion](Azure.AppService.NETVersion.md) | Configure applications to use newer .NET Framework versions. | Important
[Azure.AppService.PHPVersion](Azure.AppService.PHPVersion.md) | Configure applications to use newer PHP runtime versions. | Important
[Azure.AppService.PlanInstanceCount](Azure.AppService.PlanInstanceCount.md) | Use an App Service Plan with at least two (2) instances. | Important
[Azure.AppService.RemoteDebug](Azure.AppService.RemoteDebug.md) | Disable remote debugging on App Service apps when not in use. | Important
[Azure.AppService.UseHTTPS](Azure.AppService.UseHTTPS.md) | Azure App Service apps should only accept encrypted connections. | Important
[Azure.Automation.EncryptVariables](Azure.Automation.EncryptVariables.md) | Azure Automation variables should be encrypted. | Important
[Azure.Automation.WebHookExpiry](Azure.Automation.WebHookExpiry.md) | Do not create webhooks with an expiry time greater than 1 year (default). | Awareness
[Azure.CDN.EndpointName](Azure.CDN.EndpointName.md) | Azure CDN Endpoint names should meet naming requirements. | Awareness
[Azure.CDN.HTTP](Azure.CDN.HTTP.md) | Enforce HTTPS for client connections. | Important
[Azure.CDN.MinTLS](Azure.CDN.MinTLS.md) | Azure CDN endpoints should reject TLS versions older than 1.2. | Important
[Azure.DataFactory.Version](Azure.DataFactory.Version.md) | Consider migrating to DataFactory v2. | Awareness
[Azure.Firewall.Mode](Azure.Firewall.Mode.md) | Deny high confidence malicious IP addresses and domains. | Critical
[Azure.FrontDoor.Logs](Azure.FrontDoor.Logs.md) | Audit and monitor access through Front Door. | Important
[Azure.FrontDoor.MinTLS](Azure.FrontDoor.MinTLS.md) | Front Door should reject TLS versions older then 1.2. | Critical
[Azure.FrontDoor.Name](Azure.FrontDoor.Name.md) | Front Door names should meet naming requirements. | Awareness
[Azure.FrontDoor.State](Azure.FrontDoor.State.md) | Enable Azure Front Door instance. | Awareness
[Azure.FrontDoor.UseWAF](Azure.FrontDoor.UseWAF.md) | Enable Web Application Firewall (WAF) policies on each Front Door endpoint. | Critical
[Azure.FrontDoor.WAF.Enabled](Azure.FrontDoor.WAF.Enabled.md) | Front Door Web Application Firewall (WAF) policy must be enabled to protect back end resources. | Critical
[Azure.FrontDoor.WAF.Mode](Azure.FrontDoor.WAF.Mode.md) | Use protection mode in Front Door Web Application Firewall (WAF) policies to protect back end resources. | Critical
[Azure.FrontDoor.WAF.Name](Azure.FrontDoor.WAF.Name.md) | Front Door WAF policy names should meet naming requirements. | Awareness
[Azure.KeyVault.AccessPolicy](Azure.KeyVault.AccessPolicy.md) | Use the principal of least privilege when assigning access to Key Vault. | Important
[Azure.KeyVault.Logs](Azure.KeyVault.Logs.md) | Audit and monitor access to Key Vault data. | Important
[Azure.KeyVault.PurgeProtect](Azure.KeyVault.PurgeProtect.md) | Enable Purge Protection on Key Vaults to prevent early purge of vaults and vault items. | Important
[Azure.KeyVault.SoftDelete](Azure.KeyVault.SoftDelete.md) | Enable Soft Delete on Key Vaults to protect vaults and vault items from accidental deletion. | Important
[Azure.LB.Name](Azure.LB.Name.md) | Load Balancer names should meet naming requirements. | Awareness
[Azure.LB.Probe](Azure.LB.Probe.md) | Use a specific probe for web protocols. | Important
[Azure.LogicApp.LimitHTTPTrigger](Azure.LogicApp.LimitHTTPTrigger.md) | Limit HTTP request trigger access to trusted IP addresses. | Critical
[Azure.Monitor.ServiceHealth](Azure.Monitor.ServiceHealth.md) | Configure Service Health alerts to notify administrators. | Important
[Azure.MySQL.AllowAzureAccess](Azure.MySQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.MySQL.FirewallIPRange](Azure.MySQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important
[Azure.MySQL.FirewallRuleCount](Azure.MySQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
[Azure.MySQL.MinTLS](Azure.MySQL.MinTLS.md) | MySQL DB servers should reject TLS versions older than 1.2. | Critical
[Azure.MySQL.UseSSL](Azure.MySQL.UseSSL.md) | Enforce encrypted MySQL connections. | Critical
[Azure.NSG.AnyInboundSource](Azure.NSG.AnyInboundSource.md) | Network security groups (NSGs) should avoid rules that allow any inbound source. | Critical
[Azure.NSG.Associated](Azure.NSG.Associated.md) | Network Security Groups (NSGs) should be associated. | Awareness
[Azure.NSG.DenyAllInbound](Azure.NSG.DenyAllInbound.md) | Avoid denying all inbound traffic. | Important
[Azure.NSG.LateralTraversal](Azure.NSG.LateralTraversal.md) | Deny outbound management connections from non-management hosts. | Important
[Azure.NSG.Name](Azure.NSG.Name.md) | Network Security Group (NSG) names should meet naming requirements. | Awareness
[Azure.Policy.Descriptors](Azure.Policy.Descriptors.md) | Policy and initiative definitions should use a display name, description and category. | Awareness
[Azure.PostgreSQL.AllowAzureAccess](Azure.PostgreSQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.PostgreSQL.FirewallIPRange](Azure.PostgreSQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important
[Azure.PostgreSQL.FirewallRuleCount](Azure.PostgreSQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
[Azure.PostgreSQL.MinTLS](Azure.PostgreSQL.MinTLS.md) | PostgreSQL DB servers should reject TLS versions older than 1.2. | Critical
[Azure.PostgreSQL.UseSSL](Azure.PostgreSQL.UseSSL.md) | Enforce encrypted PostgreSQL connections. | Critical
[Azure.PublicIP.DNSLabel](Azure.PublicIP.DNSLabel.md) | Public IP domain name labels should meet naming requirements. | Awareness
[Azure.PublicIP.IsAttached](Azure.PublicIP.IsAttached.md) | Public IP address should be attached or removed. | Important
[Azure.PublicIP.Name](Azure.PublicIP.Name.md) | Public IP names should meet naming requirements. | Awareness
[Azure.RBAC.CoAdministrator](Azure.RBAC.CoAdministrator.md) | Delegate access to manage Azure resources using role-based access control (RBAC). | Important
[Azure.RBAC.LimitMGDelegation](Azure.RBAC.LimitMGDelegation.md) | Limit Role-Base Access Control (RBAC) inheritance from Management Groups. | Important
[Azure.RBAC.LimitOwner](Azure.RBAC.LimitOwner.md) | Limit the number of subscription Owners. | Important
[Azure.RBAC.PIM](Azure.RBAC.PIM.md) | Use just-in-time (JiT) activation of roles instead of persistent role assignment. | Important
[Azure.RBAC.UseGroups](Azure.RBAC.UseGroups.md) | Use groups for assigning permissions instead of individual user accounts. | Important
[Azure.RBAC.UseRGDelegation](Azure.RBAC.UseRGDelegation.md) | Use RBAC assignments on resource groups instead of individual resources. | Important
[Azure.Redis.MaxMemoryReserved](Azure.Redis.MaxMemoryReserved.md) | Configure maxmemory-reserved to reserve memory for non-cache operations. | Important
[Azure.Redis.MinSKU](Azure.Redis.MinSKU.md) | Use Azure Cache for Redis instances of at least Standard C1. | Important
[Azure.Redis.MinTLS](Azure.Redis.MinTLS.md) | Redis Cache should reject TLS versions older then 1.2. | Critical
[Azure.Redis.NonSslPort](Azure.Redis.NonSslPort.md) | Azure Cache for Redis should only accept secure connections. | Critical
[Azure.Resource.AllowedRegions](Azure.Resource.AllowedRegions.md) | Resources should be deployed to allowed regions. | Awareness
[Azure.Resource.UseTags](Azure.Resource.UseTags.md) | Azure resources should be tagged using a standard convention. | Awareness
[Azure.ResourceGroup.Name](Azure.ResourceGroup.Name.md) | Resource Group names should meet naming requirements. | Awareness
[Azure.Route.Name](Azure.Route.Name.md) | Route table names should meet naming requirements. | Awareness
[Azure.SecurityCenter.Contact](Azure.SecurityCenter.Contact.md) | Security Center email and phone contact details should be set. | Important
[Azure.SecurityCenter.Provisioning](Azure.SecurityCenter.Provisioning.md) | Enable auto-provisioning on to improve Azure Security Center insights. | Important
[Azure.SignalR.Name](Azure.SignalR.Name.md) | SignalR service instance names should meet naming requirements. | Awareness
[Azure.SQL.AAD](Azure.SQL.AAD.md) | Use Azure Active Directory (AAD) authentication with Azure SQL databases. | Critical
[Azure.SQL.AllowAzureAccess](Azure.SQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.SQL.Auditing](Azure.SQL.Auditing.md) | Enable auditing for Azure SQL logical server. | Important
[Azure.SQL.FirewallIPRange](Azure.SQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important
[Azure.SQL.FirewallRuleCount](Azure.SQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
[Azure.SQL.MinTLS](Azure.SQL.MinTLS.md) | Azure SQL Database servers should reject TLS versions older than 1.2. | Critical
[Azure.SQL.TDE](Azure.SQL.TDE.md) | Use Transparent Data Encryption (TDE) with Azure SQL Database. | Critical
[Azure.SQL.ThreatDetection](Azure.SQL.ThreatDetection.md) | Enable Advanced Thread Protection for Azure SQL logical server. | Important
[Azure.Storage.BlobAccessType](Azure.Storage.BlobAccessType.md) | Storage Accounts use containers configured with an access type other than Private. | Important
[Azure.Storage.BlobPublicAccess](Azure.Storage.BlobPublicAccess.md) | Storage Accounts should only accept authorized requests. | Important
[Azure.Storage.MinTLS](Azure.Storage.MinTLS.md) | Storage Accounts should reject TLS versions older than 1.2. | Critical
[Azure.Storage.Name](Azure.Storage.Name.md) | Storage Account names should meet naming requirements. | Awareness
[Azure.Storage.SecureTransfer](Azure.Storage.SecureTransfer.md) | Storage accounts should only accept encrypted connections. | Important
[Azure.Storage.SoftDelete](Azure.Storage.SoftDelete.md) | Enable blob soft delete on Storage Accounts. | Important
[Azure.Storage.UseEncryption](Azure.Storage.UseEncryption.md) | Storage Service Encryption (SSE) should be enabled. | Important
[Azure.Storage.UseReplication](Azure.Storage.UseReplication.md) | Storage Accounts not using geo-replicated storage (GRS) may be at risk. | Important
[Azure.Template.ParameterFile](Azure.Template.ParameterFile.md) | Use ARM template parameter files that are valid. | Important
[Azure.Template.ParameterMetadata](Azure.Template.ParameterMetadata.md) | Set metadata descriptions in Azure Resource Manager (ARM) template for each parameter. | Awareness
[Azure.Template.Resources](Azure.Template.Resources.md) | Each Azure Resource Manager (ARM) template file should deploy at least one resource. | Awareness
[Azure.Template.TemplateFile](Azure.Template.TemplateFile.md) | Use ARM template files that are valid. | Important
[Azure.Template.UseParameters](Azure.Template.UseParameters.md) | Each Azure Resource Manager (ARM) template parameter should be used or removed from template files. | Awareness
[Azure.Template.UseVariables](Azure.Template.UseVariables.md) | Each Azure Resource Manager (ARM) template variable should be used or removed from template files. | Awareness
[Azure.TrafficManager.Endpoints](Azure.TrafficManager.Endpoints.md) | Traffic Manager should use at lest two enabled endpoints. | Important
[Azure.TrafficManager.Protocol](Azure.TrafficManager.Protocol.md) | Monitor Traffic Manager web-based endpoints with HTTPS. | Important
[Azure.VM.AcceleratedNetworking](Azure.VM.AcceleratedNetworking.md) | Use accelerated networking for supported operating systems and VM types. | Important
[Azure.VM.ADE](Azure.VM.ADE.md) | Use Azure Disk Encryption (ADE). | Important
[Azure.VM.Agent](Azure.VM.Agent.md) | Ensure the VM agent is provisioned automatically. | Important
[Azure.VM.ASAlignment](Azure.VM.ASAlignment.md) | Availability sets should be aligned. | Important
[Azure.VM.ASMinMembers](Azure.VM.ASMinMembers.md) | Availability sets should be deployed with at least two members. | Important
[Azure.VM.ASName](Azure.VM.ASName.md) | Availability Set names should meet naming requirements. | Awareness
[Azure.VM.BasicSku](Azure.VM.BasicSku.md) | Virtual machines (VMs) should not use Basic sizes. | Important
[Azure.VM.ComputerName](Azure.VM.ComputerName.md) | Virtual Machine (VM) computer name should meet naming requirements. | Awareness
[Azure.VM.DiskAttached](Azure.VM.DiskAttached.md) | Managed disks should be attached to virtual machines or removed. | Important
[Azure.VM.DiskCaching](Azure.VM.DiskCaching.md) | Check disk caching is configured correctly for the workload. | Important
[Azure.VM.DiskName](Azure.VM.DiskName.md) | Managed Disk names should meet naming requirements. | Awareness
[Azure.VM.DiskSizeAlignment](Azure.VM.DiskSizeAlignment.md) | Align to the Managed Disk billing model to improve cost efficiency. | Awareness
[Azure.VM.Name](Azure.VM.Name.md) | Virtual Machine (VM) names should meet naming requirements. | Awareness
[Azure.VM.NICAttached](Azure.VM.NICAttached.md) | Network interfaces (NICs) should be attached. | Awareness
[Azure.VM.NICName](Azure.VM.NICName.md) | Network Interface (NIC) names should meet naming requirements. | Awareness
[Azure.VM.PPGName](Azure.VM.PPGName.md) | Proximity Placement Group (PPG) names should meet naming requirements. | Awareness
[Azure.VM.PromoSku](Azure.VM.PromoSku.md) | Virtual machines (VMs) should not use expired promotional SKU. | Awareness
[Azure.VM.PublicKey](Azure.VM.PublicKey.md) | Linux virtual machines should use public keys. | Important
[Azure.VM.Standalone](Azure.VM.Standalone.md) | VMs must use premium disks or use availability sets/ zones to meet SLA requirements. | Important
[Azure.VM.UniqueDns](Azure.VM.UniqueDns.md) | Network interfaces (NICs) should inherit DNS from virtual networks. | Awareness
[Azure.VM.Updates](Azure.VM.Updates.md) | Ensure automatic updates are enabled at deployment. | Important
[Azure.VM.UseHybridUseBenefit](Azure.VM.UseHybridUseBenefit.md) | Use Hybrid Use Benefit (HUB) for applicable virtual machine (VM) workloads. | Awareness
[Azure.VM.UseManagedDisks](Azure.VM.UseManagedDisks.md) | Virtual machines (VMs) should use managed disks. | Important
[Azure.VMSS.ComputerName](Azure.VMSS.ComputerName.md) | Virtual Machine Scale Set (VMSS) computer name should meet naming requirements. | Awareness
[Azure.VMSS.Name](Azure.VMSS.Name.md) | Virtual Machine Scale Set (VMSS) names should meet naming requirements. | Awareness
[Azure.VNET.LocalDNS](Azure.VNET.LocalDNS.md) | Virtual networks (VNETs) should use Azure local DNS servers. | Important
[Azure.VNET.Name](Azure.VNET.Name.md) | Virtual Network (VNET) names should meet naming requirements. | Awareness
[Azure.VNET.PeerState](Azure.VNET.PeerState.md) | VNET peering connections must be connected. | Important
[Azure.VNET.SingleDNS](Azure.VNET.SingleDNS.md) | VNETs should have at least two DNS servers assigned. | Important
[Azure.VNET.SubnetName](Azure.VNET.SubnetName.md) | Subnet names should meet naming requirements. | Awareness
[Azure.VNET.UseNSGs](Azure.VNET.UseNSGs.md) | Subnets should have NSGs assigned. | Critical
[Azure.VNG.ConnectionName](Azure.VNG.ConnectionName.md) | Virtual Network Gateway (VNG) connection names should meet naming requirements. | Awareness
[Azure.VNG.ERLegacySKU](Azure.VNG.ERLegacySKU.md) | Migrate from legacy SKUs to improve reliability and performance of ExpressRoute (ER) gateways. | Important
[Azure.VNG.Name](Azure.VNG.Name.md) | Virtual Network Gateway (VNG) names should meet naming requirements. | Awareness
[Azure.VNG.VPNActiveActive](Azure.VNG.VPNActiveActive.md) | Use VPN gateways configured to operate in an Active-Active configuration to reduce connectivity downtime. | Important
[Azure.VNG.VPNLegacySKU](Azure.VNG.VPNLegacySKU.md) | Migrate from legacy SKUs to improve reliability and performance of VPN gateways. | Important
