# Module rule reference

## Rules

The following rules are included within `PSRule.Rules.Azure`.

### Automation

Name | Synopsis | Severity
---- | -------- | --------
[Azure.File.Parameters](Azure.File.Parameters.md) | Use ARM template parameter files that are valid. | Important
[Azure.File.Template](Azure.File.Template.md) | Use ARM template files that are valid. | Important

### Cost management

Name | Synopsis | Severity
---- | -------- | --------
[Azure.VM.DiskAttached](Azure.VM.DiskAttached.md) | Managed disks should be attached to virtual machines. | Awareness
[Azure.VM.DiskSizeAlignment](Azure.VM.DiskSizeAlignment.md) | Managed disk is smaller than SKU size. | Awareness
[Azure.VM.PromoSku](Azure.VM.PromoSku.md) | Virtual machines (VMs) should not use expired promotional SKU. | Awareness
[Azure.VM.UseHybridUseBenefit](Azure.VM.UseHybridUseBenefit.md) | Use Hybrid Use Benefit. | Awareness

### Data recovery

Name | Synopsis | Severity
---- | -------- | --------
[Azure.Storage.SoftDelete](Azure.Storage.SoftDelete.md) | Enable soft delete on Storage Accounts. | Important

### Operations management

Name | Synopsis | Severity
---- | -------- | --------
[Azure.AKS.PoolVersion](Azure.AKS.PoolVersion.md) | AKS node pools should match Kubernetes control plane version. | Important
[Azure.AKS.Version](Azure.AKS.Version.md) | AKS control plane and nodes pools should use a current stable release. | Important
[Azure.DataFactory.Version](Azure.DataFactory.Version.md) | Consider migrating to DataFactory v2. | Awareness
[Azure.MySQL.FirewallRuleCount](Azure.MySQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
[Azure.PostgreSQL.FirewallRuleCount](Azure.PostgreSQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
[Azure.PublicIP.IsAttached](Azure.PublicIP.IsAttached.md) | Public IP address should be attached. | Awareness
[Azure.Resource.AllowedRegions](Azure.Resource.AllowedRegions.md) | Resources should be deployed to allowed regions. | Awareness
[Azure.Resource.UseTags](Azure.Resource.UseTags.md) | Resources should be tagged. | Awareness
[Azure.SQL.FirewallRuleCount](Azure.SQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness
[Azure.VirtualNetwork.NICAttached](Azure.VirtualNetwork.NICAttached.md) | Network interfaces (NICs) should be attached. | Awareness
[Azure.VirtualNetwork.NSGAssociated](Azure.VirtualNetwork.NSGAssociated.md) | Network Security Groups (NSGs) should be associated. | Awareness
[Azure.VirtualNetwork.PeerState](Azure.VirtualNetwork.PeerState.md) | VNET peering connections must be connected. | Important
[Azure.VM.Agent](Azure.VM.Agent.md) | Ensure the VM agent is provisioned automatically. | Important
[Azure.VM.UniqueDns](Azure.VM.UniqueDns.md) | Network interfaces (NICs) should inherit DNS from virtual networks. | Awareness
[Azure.VM.Updates](Azure.VM.Updates.md) | Ensure automatic updates are enabled at deployment. | Important

### Performance

Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.MinSku](Azure.ACR.MinSku.md) | ACR should use the Premium or Standard SKU for production deployments. | Important
[Azure.AppService.ARRAffinity](Azure.AppService.ARRAffinity.md) | Disable client affinity for stateless services. | Awareness
[Azure.AppService.MinPlan](Azure.AppService.MinPlan.md) | Use at least a Standard App Service Plan. | Important
[Azure.VirtualNetwork.AppGwMinSku](Azure.VirtualNetwork.AppGwMinSku.md) | Application Gateway should use a minimum instance size of Medium. | Important
[Azure.VM.BasicSku](Azure.VM.BasicSku.md) | Virtual machines (VMs) should not use Basic sizes. | Important
[Azure.VM.DiskCaching](Azure.VM.DiskCaching.md) | Check disk caching is configured correctly for the workload. | Important

### Performance optimisation

Name | Synopsis | Severity
---- | -------- | --------
[Azure.VM.AcceleratedNetworking](Azure.VM.AcceleratedNetworking.md) | Enabled accelerated networking for supported operating systems. | Important

### Reliability

Name | Synopsis | Severity
---- | -------- | --------
[Azure.AKS.MinNodeCount](Azure.AKS.MinNodeCount.md) | AKS clusters should have minimum number of nodes for failover and updates. | Important
[Azure.AppService.PlanInstanceCount](Azure.AppService.PlanInstanceCount.md) | Use an App Service Plan with at least two (2) instances. | Single point of failure
[Azure.Storage.UseReplication](Azure.Storage.UseReplication.md) | Storage accounts not using GRS may be at risk. | Single point of failure
[Azure.VirtualNetwork.AppGwMinInstance](Azure.VirtualNetwork.AppGwMinInstance.md) | Application Gateways should use a minimum of two instances. | Important
[Azure.VirtualNetwork.LocalDNS](Azure.VirtualNetwork.LocalDNS.md) | Virtual networks (VNETs) should use Azure local DNS servers. | Important
[Azure.VirtualNetwork.NSGDenyAllInbound](Azure.VirtualNetwork.NSGDenyAllInbound.md) | Avoid denying all inbound traffic. | Important
[Azure.VirtualNetwork.SingleDNS](Azure.VirtualNetwork.SingleDNS.md) | VNETs should have at least two DNS servers assigned. | Single point of failure
[Azure.VM.ASAlignment](Azure.VM.ASAlignment.md) | Availability sets should be aligned. | Single point of failure
[Azure.VM.ASMinMembers](Azure.VM.ASMinMembers.md) | Availability sets should be deployed with at least two members. | Single point of failure
[Azure.VM.Standalone](Azure.VM.Standalone.md) | VMs must use premium disks or use availability sets/ zones to meet SLA requirements. | Single point of failure
[Azure.VM.UseManagedDisks](Azure.VM.UseManagedDisks.md) | Virtual machines should use managed disks. | Single point of failure

### Resiliency

Name | Synopsis | Severity
---- | -------- | --------
[Azure.VirtualNetwork.LBProbe](Azure.VirtualNetwork.LBProbe.md) | Use a specific probe for web protocols. | Important

### Scalability

Name | Synopsis | Severity
---- | -------- | --------
[Azure.AKS.PoolScaleSet](Azure.AKS.PoolScaleSet.md) | Deploy AKS clusters with nodes pools based on VM scale sets. | Important

### Security configuration

Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.AdminUser](Azure.ACR.AdminUser.md) | Use Azure AD accounts instead of using the registry admin user. | Critical
[Azure.AKS.NetworkPolicy](Azure.AKS.NetworkPolicy.md) | Deploy AKS clusters with Azure Network Policies enabled. | Important
[Azure.AKS.PodSecurityPolicy](Azure.AKS.PodSecurityPolicy.md) | Configure AKS non-production clusters to use Pod Security Policies (Preview). | Important
[Azure.AKS.UseRBAC](Azure.AKS.UseRBAC.md) | Deploy AKS cluster with role-based access control (RBAC) enabled. | Important
[Azure.AppService.MinTLS](Azure.AppService.MinTLS.md) | App Service should reject TLS versions older then 1.2. | Important
[Azure.AppService.UseHTTPS](Azure.AppService.UseHTTPS.md) | Azure App Service apps should only accept encrypted connections. | Important
[Azure.Automation.EncryptVariables](Azure.Automation.EncryptVariables.md) | Azure Automation variables should be encrypted. | Important
[Azure.Automation.WebHookExpiry](Azure.Automation.WebHookExpiry.md) | Do not create webhooks with an expiry time greater than 1 year (default). | Awareness
[Azure.MySQL.AllowAzureAccess](Azure.MySQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.MySQL.FirewallIPRange](Azure.MySQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important
[Azure.MySQL.UseSSL](Azure.MySQL.UseSSL.md) | Enforce encrypted MySQL connections. | Critical
[Azure.PostgreSQL.AllowAzureAccess](Azure.PostgreSQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.PostgreSQL.FirewallIPRange](Azure.PostgreSQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important
[Azure.PostgreSQL.UseSSL](Azure.PostgreSQL.UseSSL.md) | Enforce encrypted PostgreSQL connections. | Critical
[Azure.Redis.MinTLS](Azure.Redis.MinTLS.md) | Redis Cache should reject TLS versions older then 1.2. | Critical
[Azure.Redis.NonSslPort](Azure.Redis.NonSslPort.md) | Redis Cache should only accept secure connections. | Critical
[Azure.SQL.AllowAzureAccess](Azure.SQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important
[Azure.SQL.Auditing](Azure.SQL.Auditing.md) | Enable auditing for Azure SQL logical server. | Important
[Azure.SQL.FirewallIPRange](Azure.SQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important
[Azure.SQL.ThreatDetection](Azure.SQL.ThreatDetection.md) | Enable Advanced Thread Protection for Azure SQL logical server. | Important
[Azure.Storage.SecureTransferRequired](Azure.Storage.SecureTransferRequired.md) | Storage accounts should only accept encrypted connections. | Important
[Azure.Storage.UseEncryption](Azure.Storage.UseEncryption.md) | Storage Service Encryption (SSE) should be enabled. | Important
[Azure.VirtualNetwork.AppGwOWASP](Azure.VirtualNetwork.AppGwOWASP.md) | Application Gateway Web Application Firewall (WAF) should use OWASP 3.x rules. | Important
[Azure.VirtualNetwork.AppGwPrevention](Azure.VirtualNetwork.AppGwPrevention.md) | Internet exposed Application Gateways should use prevention mode to protect backend resources. | Critical
[Azure.VirtualNetwork.AppGwSSLPolicy](Azure.VirtualNetwork.AppGwSSLPolicy.md) | Application Gateway should only accept a minimum of TLS 1.2. | Critical
[Azure.VirtualNetwork.AppGwUseWAF](Azure.VirtualNetwork.AppGwUseWAF.md) | Internet accessible Application Gateways should use WAF. | Critical
[Azure.VirtualNetwork.AppGwWAFEnabled](Azure.VirtualNetwork.AppGwWAFEnabled.md) | Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources. | Critical
[Azure.VirtualNetwork.AppGwWAFRules](Azure.VirtualNetwork.AppGwWAFRules.md) | Application Gateway Web Application Firewall (WAF) should have all rules enabled. | Important
[Azure.VirtualNetwork.LateralTraversal](Azure.VirtualNetwork.LateralTraversal.md) | Deny outbound management connections from non-management hosts. | Important
[Azure.VirtualNetwork.NSGAnyInboundSource](Azure.VirtualNetwork.NSGAnyInboundSource.md) | Network security groups should avoid any inbound rules. | Critical
[Azure.VirtualNetwork.UseNSGs](Azure.VirtualNetwork.UseNSGs.md) | Subnets should have NSGs assigned. | Critical
[Azure.VM.ADE](Azure.VM.ADE.md) | Use Azure Disk Encryption. | Important
[Azure.VM.PublicKey](Azure.VM.PublicKey.md) | Linux virtual machines should use public keys. | Important

### Security operations

Name | Synopsis | Severity
---- | -------- | --------
[Azure.RBAC.CoAdministrator](Azure.RBAC.CoAdministrator.md) | Delegate access to manage Azure resources using role-based access control (RBAC). | Important
[Azure.RBAC.LimitMGDelegation](Azure.RBAC.LimitMGDelegation.md) | Limit Role-Base Access Control (RBAC) inheritance from Management Groups. | Important
[Azure.RBAC.LimitOwner](Azure.RBAC.LimitOwner.md) | Limit the number of subscription Owners. | Important
[Azure.RBAC.UseGroups](Azure.RBAC.UseGroups.md) | Use groups for assigning permissions instead of individual user accounts. | Important
[Azure.RBAC.UseRGDelegation](Azure.RBAC.UseRGDelegation.md) | Use RBAC assignments on resource groups instead of individual resources. | Important
[Azure.SecurityCenter.Contact](Azure.SecurityCenter.Contact.md) | Security Center email and phone contact details should be set. | Important
[Azure.SecurityCenter.Provisioning](Azure.SecurityCenter.Provisioning.md) | Enable auto-provisioning on to improve Azure Security Center insights. | Important
