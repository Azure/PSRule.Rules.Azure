---
generated-by: PSDocs
---

# Azure rules

RuleName | Description
-------- | -----------
Azure.ACR.AdminUser | Use RBAC for delegating access to ACR instead of the registry admin user
Azure.ACR.MinSku | ACR should use the Premium or Standard SKU for production deployments
Azure.AKS.MinNodeCount | AKS clusters should have minimum number of nodes for failover and updates
Azure.AKS.Version | AKS cluster should meet the minimum version
Azure.AKS.UseRBAC | AKS cluster should use role-based access control
Azure.AppService.PlanInstanceCount | Use an App Service Plan with at least two (2) instances
Azure.AppService.MinPlan | Use at least a Standard App Service Plan
Azure.AppService.ARRAfinity | Disable client affinity for stateless services
Azure.AppService.UseHTTPS | Use HTTPS only
Azure.DataFactory.Version | Consider migrating to DataFactory v2
Azure.MySQL.UseSSL | Use encrypted MySQL connections
Azure.PublicIP.IsAttached | Public IP addresses should be attached or cleaned up if not in use
Azure.Redis.NonSslPort | Redis Cache should only accept secure connections
Azure.Redis.MinTLS | Redis Cache should reject TLS versions older then 1.2
Azure.Resource.UseTags | Resources should be tagged
Azure.Resource.AllowedRegions | Resources should be deployed to allowed regions
Azure.SQL.FirewallRuleCount | Determine if there is an excessive number of firewall rules
Azure.SQL.AllowAzureAccess | Determine if access from Azure servers is required
Azure.SQL.ThreatDetection | Enable threat detection for Azure SQL logical server
Azure.SQL.Auditing | Enable auditing for Azure SQL logical server
Azure.Storage.UseReplication | Storage accounts not using GRS may be at risk
Azure.Storage.SecureTransferRequired | Storage accounts should only accept secure traffic
Azure.Storage.UseEncryption | Storage Service Encryption (SSE) should be enabled
Azure.Storage.SoftDelete | Enable soft delete on Storage Accounts
Azure.Subscription.SecurityCenterContact | Security Center email and phone contact details should be set
Azure.Subscription.SecurityCenterProvisioning | Enable auto-provisioning on VMs to improve Security Center insights
Azure.VirtualMachine.UseManagedDisks | Virtual machines should use managed disks
Azure.VirtualMachine.Standalone | VMs much use premium disks or use availablity sets/ zones to meet SLA requirements
Azure.VirtualMachine.DiskCaching | Check disk caching is configured correctly for the workload
Azure.VirtualMachine.UniqueDns | Network interfaces should inherit from virtual network
Azure.VirtualMachine.DiskAttached | Managed disks should be attached to virtual machines
Azure.VirtualMachine.DiskSizeAlignment | Managed disk is smaller than SKU size
Azure.VirtualMachine.UseHybridUseBenefit | Use Hybrid Use Benefit
Azure.VirtualMachine.AcceleratedNetworking | Enabled accelerated networking for supported operating systems
Azure.VirtualMachine.ASAlignment | Availablity sets should be aligned
Azure.VirtualMachine.ASMinMembers | Availablity sets should be deployed with at least two members
Azure.VirtualNetwork.UseNSGs | Subnets should have NSGs assigned, except for the GatewaySubnet
Azure.VirtualNetwork.SingleDNS | VNETs should have at least two DNS servers assigned
Azure.VirtualNetwork.NSGAnyInboundSource | Network security groups should avoid any inbound rules
Azure.VirtualNetwork.AppGwMinInstance | Application Gateway should use a minimum of two instances
Azure.VirtualNetwork.AppGwMinSku | Application Gateway should use a minimum of Medium
Azure.VirtualNetwork.AppGwUseWAF | Internet accessible Application Gateways should use WAF
Azure.VirtualNetwork.AppGwSSLPolicy | Application Gateway should only accept a minimum of TLS 1.2
Azure.VirtualNetwork.AppGwPrevention | Internet exposed Application Gateways should use prevention mode to protect backend resources
