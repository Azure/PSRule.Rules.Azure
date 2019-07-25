# Azure rules

RuleName | Description | Category
-------- | ----------- | --------
[Azure.ACR.AdminUser](Azure.ACR.AdminUser.md) | Use Azure AD accounts instead of using the registry admin user. | Security configuration
[Azure.ACR.MinSku](Azure.ACR.MinSku.md) | ACR should use the Premium or Standard SKU for production deployments. | Performance
[Azure.AKS.MinNodeCount](Azure.AKS.MinNodeCount.md) | AKS clusters should have minimum number of nodes for failover and updates. | Reliability
[Azure.AKS.Version](Azure.AKS.Version.md) | AKS clusters should meet the minimum version. | Operations management
[Azure.AKS.UseRBAC](Azure.AKS.UseRBAC.md) | AKS cluster should use role-based access control (RBAC). | Security configuration
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
[Azure.Subscription.SecurityCenterContact](Azure.Subscription.SecurityCenterContact.md) | Security Center email and phone contact details should be set. | Security operations
[Azure.Subscription.SecurityCenterProvisioning](Azure.Subscription.SecurityCenterProvisioning.md) | Enable auto-provisioning on VMs to improve Security Center insights. | Security operations
[Azure.VirtualMachine.UseManagedDisks](Azure.VirtualMachine.UseManagedDisks.md) | Virtual machines should use managed disks. | Reliability
[Azure.VirtualMachine.Standalone](Azure.VirtualMachine.Standalone.md) | VMs much use premium disks or use availability sets/ zones to meet SLA requirements. | Reliability
[Azure.VirtualMachine.PromoSku](Azure.VirtualMachine.PromoSku.md) | Virtual machines (VMs) should not use expired promotional SKU. | Cost management
[Azure.VirtualMachine.BasicSku](Azure.VirtualMachine.BasicSku.md) | Virtual machines (VMs) should not use Basic sizes. | Performance
[Azure.VirtualMachine.DiskCaching](Azure.VirtualMachine.DiskCaching.md) | Check disk caching is configured correctly for the workload. | Performance
[Azure.VirtualMachine.UniqueDns](Azure.VirtualMachine.UniqueDns.md) | Network interfaces should inherit from virtual network. | Operations management
[Azure.VirtualMachine.DiskAttached](Azure.VirtualMachine.DiskAttached.md) | Managed disks should be attached to virtual machines. | Operations management
[Azure.VirtualMachine.DiskSizeAlignment](Azure.VirtualMachine.DiskSizeAlignment.md) | Managed disk is smaller than SKU size. | Cost management
[Azure.VirtualMachine.UseHybridUseBenefit](Azure.VirtualMachine.UseHybridUseBenefit.md) | Use Hybrid Use Benefit. | Cost management
[Azure.VirtualMachine.AcceleratedNetworking](Azure.VirtualMachine.AcceleratedNetworking.md) | Enabled accelerated networking for supported operating systems. | Performance optimisation
[Azure.VirtualMachine.ASAlignment](Azure.VirtualMachine.ASAlignment.md) | Availability sets should be aligned. | Reliability
[Azure.VirtualMachine.ASMinMembers](Azure.VirtualMachine.ASMinMembers.md) | Availability sets should be deployed with at least two members. | Reliability
[Azure.VirtualNetwork.UseNSGs](Azure.VirtualNetwork.UseNSGs.md) | Subnets should have NSGs assigned. | Security configuration
[Azure.VirtualNetwork.SingleDNS](Azure.VirtualNetwork.SingleDNS.md) | VNETs should have at least two DNS servers assigned. | Reliability
[Azure.VirtualNetwork.LocalDNS](Azure.VirtualNetwork.LocalDNS.md) | Virtual networks (VNETs) should use Azure local DNS servers. | Reliability
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
