# Azure rules

RuleName | Description
-------- | -----------
[Azure.ACR.AdminUser](Azure.ACR.AdminUser.md) | Use RBAC for delegating access to ACR instead of the registry admin user
[Azure.ACR.MinSku](Azure.ACR.MinSku.md) | ACR should use the Premium or Standard SKU for production deployments
[Azure.AKS.MinNodeCount](Azure.AKS.MinNodeCount.md) | AKS clusters should have minimum number of nodes for failover and updates
[Azure.AKS.Version](Azure.AKS.Version.md) | AKS cluster should meet the minimum version
[Azure.AKS.UseRBAC](Azure.AKS.UseRBAC.md) | AKS cluster should use role-based access control
[Azure.AppService.PlanInstanceCount](Azure.AppService.PlanInstanceCount.md) | Use an App Service Plan with at least two (2) instances
[Azure.AppService.MinPlan](Azure.AppService.MinPlan.md) | Use at least a Standard App Service Plan
[Azure.AppService.ARRAffinity](Azure.AppService.ARRAffinity.md) | Disable client affinity for stateless services
[Azure.AppService.UseHTTPS](Azure.AppService.UseHTTPS.md) | Use HTTPS only
[Azure.DataFactory.Version](Azure.DataFactory.Version.md) | Consider migrating to DataFactory v2
[Azure.MySQL.UseSSL](Azure.MySQL.UseSSL.md) | Use encrypted MySQL connections
[Azure.MySQL.FirewallRuleCount](Azure.MySQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules
[Azure.MySQL.AllowAzureAccess](Azure.MySQL.AllowAzureAccess.md) | Determine if access from Azure services is required
[Azure.PostgreSQL.UseSSL](Azure.PostgreSQL.UseSSL.md) | Use encrypted PostgreSQL connections
[Azure.PostgreSQL.FirewallRuleCount](Azure.PostgreSQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules
[Azure.PostgreSQL.AllowAzureAccess](Azure.PostgreSQL.AllowAzureAccess.md) | Determine if access from Azure services is required
[Azure.PublicIP.IsAttached](Azure.PublicIP.IsAttached.md) | Public IP addresses should be attached or cleaned up if not in use
[Azure.Redis.NonSslPort](Azure.Redis.NonSslPort.md) | Redis Cache should only accept secure connections
[Azure.Redis.MinTLS](Azure.Redis.MinTLS.md) | Redis Cache should reject TLS versions older then 1.2
[Azure.Resource.UseTags](Azure.Resource.UseTags.md) | Resources should be tagged
[Azure.Resource.AllowedRegions](Azure.Resource.AllowedRegions.md) | Resources should be deployed to allowed regions
[Azure.SQL.FirewallRuleCount](Azure.SQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules
[Azure.SQL.AllowAzureAccess](Azure.SQL.AllowAzureAccess.md) | Determine if access from Azure services is required
[Azure.SQL.ThreatDetection](Azure.SQL.ThreatDetection.md) | Enable threat detection for Azure SQL logical server
[Azure.SQL.Auditing](Azure.SQL.Auditing.md) | Enable auditing for Azure SQL logical server
[Azure.Storage.UseReplication](Azure.Storage.UseReplication.md) | Storage accounts not using GRS may be at risk
[Azure.Storage.SecureTransferRequired](Azure.Storage.SecureTransferRequired.md) | Storage accounts should only accept secure traffic
[Azure.Storage.UseEncryption](Azure.Storage.UseEncryption.md) | Storage Service Encryption (SSE) should be enabled
[Azure.Storage.SoftDelete](Azure.Storage.SoftDelete.md) | Enable soft delete on Storage Accounts
[Azure.Subscription.SecurityCenterContact](Azure.Subscription.SecurityCenterContact.md) | Security Center email and phone contact details should be set
[Azure.Subscription.SecurityCenterProvisioning](Azure.Subscription.SecurityCenterProvisioning.md) | Enable auto-provisioning on VMs to improve Security Center insights
[Azure.VirtualMachine.UseManagedDisks](Azure.VirtualMachine.UseManagedDisks.md) | Virtual machines should use managed disks
[Azure.VirtualMachine.Standalone](Azure.VirtualMachine.Standalone.md) | VMs much use premium disks or use availability sets/ zones to meet SLA requirements
[Azure.VirtualMachine.DiskCaching](Azure.VirtualMachine.DiskCaching.md) | Check disk caching is configured correctly for the workload
[Azure.VirtualMachine.UniqueDns](Azure.VirtualMachine.UniqueDns.md) | Network interfaces should inherit from virtual network
[Azure.VirtualMachine.DiskAttached](Azure.VirtualMachine.DiskAttached.md) | Managed disks should be attached to virtual machines
[Azure.VirtualMachine.DiskSizeAlignment](Azure.VirtualMachine.DiskSizeAlignment.md) | Managed disk is smaller than SKU size
[Azure.VirtualMachine.UseHybridUseBenefit](Azure.VirtualMachine.UseHybridUseBenefit.md) | Use Hybrid Use Benefit
[Azure.VirtualMachine.AcceleratedNetworking](Azure.VirtualMachine.AcceleratedNetworking.md) | Enabled accelerated networking for supported operating systems
[Azure.VirtualMachine.ASAlignment](Azure.VirtualMachine.ASAlignment.md) | Availability sets should be aligned
[Azure.VirtualMachine.ASMinMembers](Azure.VirtualMachine.ASMinMembers.md) | Availability sets should be deployed with at least two members
[Azure.VirtualNetwork.UseNSGs](Azure.VirtualNetwork.UseNSGs.md) | Subnets should have NSGs assigned, except for the GatewaySubnet
[Azure.VirtualNetwork.SingleDNS](Azure.VirtualNetwork.SingleDNS.md) | VNETs should have at least two DNS servers assigned
[Azure.VirtualNetwork.NSGAnyInboundSource](Azure.VirtualNetwork.NSGAnyInboundSource.md) | Network security groups should avoid any inbound rules
[Azure.VirtualNetwork.AppGwMinInstance](Azure.VirtualNetwork.AppGwMinInstance.md) | Application Gateway should use a minimum of two instances
[Azure.VirtualNetwork.AppGwMinSku](Azure.VirtualNetwork.AppGwMinSku.md) | Application Gateway should use a minimum of Medium
[Azure.VirtualNetwork.AppGwUseWAF](Azure.VirtualNetwork.AppGwUseWAF.md) | Internet accessible Application Gateways should use WAF
[Azure.VirtualNetwork.AppGwSSLPolicy](Azure.VirtualNetwork.AppGwSSLPolicy.md) | Application Gateway should only accept a minimum of TLS 1.2
[Azure.VirtualNetwork.AppGwPrevention](Azure.VirtualNetwork.AppGwPrevention.md) | Internet exposed Application Gateways should use prevention mode to protect backend resources
