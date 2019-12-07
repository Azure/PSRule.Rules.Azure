# Azure rules

RuleName | Description | Category
-------- | ----------- | --------
[Azure.ACR.AdminUser](Azure.ACR.AdminUser.md) | Use Azure AD accounts instead of using the registry admin user. | Security configuration
[Azure.ACR.MinSku](Azure.ACR.MinSku.md) | ACR should use the Premium or Standard SKU for production deployments. | Performance
[Azure.AKS.MinNodeCount](Azure.AKS.MinNodeCount.md) | AKS clusters should have minimum number of nodes for failover and updates. | Reliability
[Azure.AKS.Version](Azure.AKS.Version.md) | AKS control plane and nodes pools should use a current stable release. | Operations management
[Azure.AKS.PoolVersion](Azure.AKS.PoolVersion.md) | AKS node pools should match Kubernetes control plane version. | Operations management
[Azure.AKS.UseRBAC](Azure.AKS.UseRBAC.md) | Deploy AKS cluster with role-based access control (RBAC) enabled. | Security configuration
[Azure.AKS.NetworkPolicy](Azure.AKS.NetworkPolicy.md) | Deploy AKS clusters with Azure Network Policies enabled. | Security configuration
[Azure.AKS.PoolScaleSet](Azure.AKS.PoolScaleSet.md) | Deploy AKS clusters with nodes pools based on VM scale sets. | Scalability
[Azure.AppService.PlanInstanceCount](Azure.AppService.PlanInstanceCount.md) | Use an App Service Plan with at least two (2) instances. | Reliability
[Azure.AppService.MinPlan](Azure.AppService.MinPlan.md) | Use at least a Standard App Service Plan. | Performance
[Azure.AppService.ARRAffinity](Azure.AppService.ARRAffinity.md) | Disable client affinity for stateless services. | Performance
[Azure.AppService.UseHTTPS](Azure.AppService.UseHTTPS.md) | Use HTTPS only. Disable HTTP when not required. | Security configuration
[Azure.AppService.MinTLS](Azure.AppService.MinTLS.md) | App Service should reject TLS versions older then 1.2. | Security configuration
[Azure.DataFactory.Version](Azure.DataFactory.Version.md) | Consider migrating to DataFactory v2. | Operations management
[Azure.MySQL.UseSSL](Azure.MySQL.UseSSL.md) | Enforce encrypted MySQL connections. | Security configuration
[Azure.MySQL.FirewallRuleCount](Azure.MySQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Operations management
[Azure.MySQL.AllowAzureAccess](Azure.MySQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Security configuration
[Azure.MySQL.FirewallIPRange](Azure.MySQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Security configuration
[Azure.PostgreSQL.UseSSL](Azure.PostgreSQL.UseSSL.md) | Enforce encrypted PostgreSQL connections. | Security configuration
[Azure.PostgreSQL.FirewallRuleCount](Azure.PostgreSQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Operations management
[Azure.PostgreSQL.AllowAzureAccess](Azure.PostgreSQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Security configuration
[Azure.PostgreSQL.FirewallIPRange](Azure.PostgreSQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Security configuration
[Azure.PublicIP.IsAttached](Azure.PublicIP.IsAttached.md) | Public IP address should be attached. | Operations management
[Azure.Redis.NonSslPort](Azure.Redis.NonSslPort.md) | Redis Cache should only accept secure connections. | Security configuration
[Azure.Redis.MinTLS](Azure.Redis.MinTLS.md) | Redis Cache should reject TLS versions older then 1.2. | Security configuration
[Azure.Resource.UseTags](Azure.Resource.UseTags.md) | Resources should be tagged. | Operations management
[Azure.Resource.AllowedRegions](Azure.Resource.AllowedRegions.md) | Resources should be deployed to allowed regions. | Operations management
[Azure.SQL.FirewallRuleCount](Azure.SQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Operations management
[Azure.SQL.AllowAzureAccess](Azure.SQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Security configuration
[Azure.SQL.FirewallIPRange](Azure.SQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Security configuration
[Azure.SQL.ThreatDetection](Azure.SQL.ThreatDetection.md) | Enable threat detection for Azure SQL logical server. | Security configuration
[Azure.SQL.Auditing](Azure.SQL.Auditing.md) | Enable auditing for Azure SQL logical server. | Security configuration
[Azure.Storage.UseReplication](Azure.Storage.UseReplication.md) | Storage accounts not using GRS may be at risk. | Reliability
[Azure.Storage.SecureTransferRequired](Azure.Storage.SecureTransferRequired.md) | Storage accounts should only accept secure traffic. | Security configuration
[Azure.Storage.UseEncryption](Azure.Storage.UseEncryption.md) | Storage Service Encryption (SSE) should be enabled. | Security configuration
[Azure.Storage.SoftDelete](Azure.Storage.SoftDelete.md) | Enable soft delete on Storage Accounts. | Data recovery
[Azure.RBAC.UseGroups](Azure.RBAC.UseGroups.md) | Use groups for assigning permissions instead of individual user accounts. | Security operations
[Azure.RBAC.LimitOwner](Azure.RBAC.LimitOwner.md) | Limit the number of subscription Owners. | Security operations
[Azure.RBAC.LimitMGDelegation](Azure.RBAC.LimitMGDelegation.md) | Limit Role-Base Access Control (RBAC) inheritance from Management Groups. | Security operations
[Azure.RBAC.CoAdministrator](Azure.RBAC.CoAdministrator.md) | Delegate access to manage Azure resources using role-based access control (RBAC). | Security operations
[Azure.RBAC.UseRGDelegation](Azure.RBAC.UseRGDelegation.md) | Use RBAC assignments on resource groups instead of individual resources. | Security operations
[Azure.SecurityCenter.Contact](Azure.SecurityCenter.Contact.md) | Security Center email and phone contact details should be set. | Security operations
[Azure.SecurityCenter.Provisioning](Azure.SecurityCenter.Provisioning.md) | Enable auto-provisioning on to improve Azure Security Center insights. | Security operations
[Azure.VM.UseManagedDisks](Azure.VM.UseManagedDisks.md) | Virtual machines should use managed disks. | Reliability
[Azure.VM.Standalone](Azure.VM.Standalone.md) | VMs must use premium disks or use availability sets/ zones to meet SLA requirements. | Reliability
[Azure.VM.PromoSku](Azure.VM.PromoSku.md) | Virtual machines (VMs) should not use expired promotional SKU. | Cost management
[Azure.VM.BasicSku](Azure.VM.BasicSku.md) | Virtual machines (VMs) should not use Basic sizes. | Performance
[Azure.VM.DiskCaching](Azure.VM.DiskCaching.md) | Check disk caching is configured correctly for the workload. | Performance
[Azure.VM.UniqueDns](Azure.VM.UniqueDns.md) | Network interfaces (NICs) should inherit DNS from virtual networks. | Operations management
[Azure.VM.DiskAttached](Azure.VM.DiskAttached.md) | Managed disks should be attached to virtual machines. | Cost management
[Azure.VM.DiskSizeAlignment](Azure.VM.DiskSizeAlignment.md) | Managed disk is smaller than SKU size. | Cost management
[Azure.VM.UseHybridUseBenefit](Azure.VM.UseHybridUseBenefit.md) | Use Hybrid Use Benefit. | Cost management
[Azure.VM.AcceleratedNetworking](Azure.VM.AcceleratedNetworking.md) | Enabled accelerated networking for supported operating systems. | Performance optimisation
[Azure.VM.ASAlignment](Azure.VM.ASAlignment.md) | Availability sets should be aligned. | Reliability
[Azure.VM.ASMinMembers](Azure.VM.ASMinMembers.md) | Availability sets should be deployed with at least two members. | Reliability
[Azure.VM.ADE](Azure.VM.ADE.md) | Use Azure Disk Encryption. | Security configuration
[Azure.VM.PublicKey](Azure.VM.PublicKey.md) | Linux virtual machines should use public keys. | Security configuration
[Azure.VM.Agent](Azure.VM.Agent.md) | Ensure the VM agent is provisioned automatically. | Operations management
[Azure.VM.Updates](Azure.VM.Updates.md) | Ensure automatic updates are enabled at deployment. | Operations management
[Azure.VirtualNetwork.UseNSGs](Azure.VirtualNetwork.UseNSGs.md) | Subnets should have NSGs assigned. | Security configuration
[Azure.VirtualNetwork.SingleDNS](Azure.VirtualNetwork.SingleDNS.md) | VNETs should have at least two DNS servers assigned. | Reliability
[Azure.VirtualNetwork.LocalDNS](Azure.VirtualNetwork.LocalDNS.md) | Virtual networks (VNETs) should use Azure local DNS servers. | Reliability
[Azure.VirtualNetwork.PeerState](Azure.VirtualNetwork.PeerState.md) | VNET peering connections must be connected. | Operations management
[Azure.VirtualNetwork.NSGAnyInboundSource](Azure.VirtualNetwork.NSGAnyInboundSource.md) | Network security groups should avoid any inbound rules. | Security configuration
[Azure.VirtualNetwork.NSGDenyAllInbound](Azure.VirtualNetwork.NSGDenyAllInbound.md) | Avoid denying all inbound traffic. | Reliability
[Azure.VirtualNetwork.LateralTraversal](Azure.VirtualNetwork.LateralTraversal.md) | Deny outbound management connections from non-management hosts. | Security configuration
[Azure.VirtualNetwork.NSGAssociated](Azure.VirtualNetwork.NSGAssociated.md) | Network Security Groups (NSGs) should be associated. | Operations management
[Azure.VirtualNetwork.AppGwMinInstance](Azure.VirtualNetwork.AppGwMinInstance.md) | Application Gateways should use a minimum of two instances. | Reliability
[Azure.VirtualNetwork.AppGwMinSku](Azure.VirtualNetwork.AppGwMinSku.md) | Application Gateway should use a minimum instance size of Medium. | Performance
[Azure.VirtualNetwork.AppGwUseWAF](Azure.VirtualNetwork.AppGwUseWAF.md) | Internet accessible Application Gateways should use WAF. | Security configuration
[Azure.VirtualNetwork.AppGwSSLPolicy](Azure.VirtualNetwork.AppGwSSLPolicy.md) | Application Gateway should only accept a minimum of TLS 1.2. | Security configuration
[Azure.VirtualNetwork.AppGwPrevention](Azure.VirtualNetwork.AppGwPrevention.md) | Internet exposed Application Gateways should use prevention mode to protect backend resources. | Security configuration
[Azure.VirtualNetwork.AppGwWAFEnabled](Azure.VirtualNetwork.AppGwWAFEnabled.md) | Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources. | Security configuration
[Azure.VirtualNetwork.AppGwOWASP](Azure.VirtualNetwork.AppGwOWASP.md) | Application Gateway Web Application Firewall (WAF) should use OWASP 3.x rules. | Security configuration
[Azure.VirtualNetwork.AppGwWAFRules](Azure.VirtualNetwork.AppGwWAFRules.md) | Application Gateway Web Application Firewall (WAF) should have all rules enabled. | Security configuration
[Azure.VirtualNetwork.NICAttached](Azure.VirtualNetwork.NICAttached.md) | Network interfaces (NICs) should be attached. | Operations management
[Azure.VirtualNetwork.LBProbe](Azure.VirtualNetwork.LBProbe.md) | Use a specific probe for web protocols. | Resiliency
