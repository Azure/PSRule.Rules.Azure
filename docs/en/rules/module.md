---
generated: True
---

# Rules by pillar

PSRule for Azure includes the following rules across five pillars of the Microsoft Azure Well-Architected Framework.

## Cost Optimization

### CO:03 Cost data and reporting

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.Resource.UseTags](Azure.Resource.UseTags.md) | Azure resources should be tagged using a standard convention. | Awareness | Error

### CO:04 Spending guardrails

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.DevBox.ProjectLimit](Azure.DevBox.ProjectLimit.md) | Limit the number of Dev Boxes a single user can create for a project. | Important | Error

### CO:05 Rate optimization

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.VM.UseHybridUseBenefit](Azure.VM.UseHybridUseBenefit.md) | Use Azure Hybrid Benefit for applicable virtual machine (VM) workloads. | Awareness | Error

### CO:06 Usage and billing increments

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ML.ComputeIdleShutdown](Azure.ML.ComputeIdleShutdown.md) | Configure an idle shutdown timeout for Machine Learning compute instances. | Critical | Error
[Azure.VM.DiskSizeAlignment](Azure.VM.DiskSizeAlignment.md) | Align to the Managed Disk billing increments to improve cost efficiency. | Awareness | Error

### CO:07 Component costs

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ACR.Usage](Azure.ACR.Usage.md) | Regularly remove deprecated and unneeded images to reduce storage usage. | Important | Error

### CO:13 Personnel time

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.NIC.Attached](Azure.NIC.Attached.md) | Network interfaces (NICs) that are not used should be removed. | Awareness | Error

### CO:14 Consolidation

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ADX.Usage](Azure.ADX.Usage.md) | Regularly remove unused resources to reduce costs. | Important | Error
[Azure.EventHub.Usage](Azure.EventHub.Usage.md) | Regularly remove unused resources to reduce costs. | Important | Error
[Azure.FrontDoor.State](Azure.FrontDoor.State.md) | Enable Azure Front Door Classic instance. | Important | Error
[Azure.PublicIP.IsAttached](Azure.PublicIP.IsAttached.md) | Public IP addresses should be attached or cleaned up if not in use. | Important | Error
[Azure.ServiceBus.Usage](Azure.ServiceBus.Usage.md) | Regularly remove unused resources to reduce costs. | Important | Error

### Pricing and billing model

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.VM.PromoSku](Azure.VM.PromoSku.md) | Virtual machines (VMs) should not use expired promotional SKU. | Awareness | Error

### Resource usage

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ACR.Retention](Azure.ACR.Retention.md) | Use a retention policy to cleanup untagged manifests. | Important | Error
[Azure.VM.DiskAttached](Azure.VM.DiskAttached.md) | Managed disks should be attached to virtual machines or removed. | Important | Error
[Azure.VM.ShouldNotBeStopped](Azure.VM.ShouldNotBeStopped.md) | Azure VMs should be running or in a deallocated state. | Important | Error

## Operational Excellence

### Automation

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.AutoUpgrade](Azure.AKS.AutoUpgrade.md) | Configure AKS to automatically upgrade to newer supported AKS versions as they are made available. | Important | Error

### Configuration

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.APIM.ProductTerms](Azure.APIM.ProductTerms.md) | Set legal terms for each product registered in API Management. | Important | Error
[Azure.APIM.SampleProducts](Azure.APIM.SampleProducts.md) | Remove starter and unlimited sample products. | Awareness | Error
[Azure.NSG.DenyAllInbound](Azure.NSG.DenyAllInbound.md) | Avoid denying all inbound traffic. | Important | Error

### Deployment

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.APIM.CertificateExpiry](Azure.APIM.CertificateExpiry.md) | Renew certificates used for custom domain bindings. | Important | Error
[Azure.AppGw.MinSku](Azure.AppGw.MinSku.md) | Application Gateway should use a minimum instance size of Medium. | Important | Error
[Azure.AppInsights.Workspace](Azure.AppInsights.Workspace.md) | Configure Application Insights resources to store data in workspaces. | Important | Error
[Azure.DataFactory.Version](Azure.DataFactory.Version.md) | Consider migrating to DataFactory v2. | Awareness | Error
[Azure.NIC.UniqueDns](Azure.NIC.UniqueDns.md) | Network interfaces (NICs) should inherit DNS from virtual networks. | Awareness | Error
[Azure.VM.BasicSku](Azure.VM.BasicSku.md) | Virtual machines (VMs) should not use Basic sizes. | Important | Error
[Azure.VM.Updates](Azure.VM.Updates.md) | Ensure automatic updates are enabled at deployment. | Important | Error
[Azure.VNG.ERLegacySKU](Azure.VNG.ERLegacySKU.md) | Migrate from legacy SKUs to improve reliability and performance of ExpressRoute (ER) gateways. | Important | Error
[Azure.VNG.VPNLegacySKU](Azure.VNG.VPNLegacySKU.md) | Migrate from legacy SKUs to improve reliability and performance of VPN gateways. | Important | Error

### Infrastructure provisioning

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AppGw.MigrateV2](Azure.AppGw.MigrateV2.md) | Use a Application Gateway v2 SKU. | Important | Error
[Azure.ASE.MigrateV3](Azure.ASE.MigrateV3.md) | Use ASEv3 as replacement for the classic app service environment versions ASEv1 and ASEv2. | Important | Error

### Instrumentation

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.APIM.APIDescriptors](Azure.APIM.APIDescriptors.md) | API Management APIs should have a display name and description. | Awareness | Warning

### Monitor

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.VNET.PeerState](Azure.VNET.PeerState.md) | VNET peering connections must be connected. | Important | Error

### Monitoring

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.ContainerInsights](Azure.AKS.ContainerInsights.md) | Enable Container insights to monitor AKS cluster workloads. | Important | Error
[Azure.AKS.PlatformLogs](Azure.AKS.PlatformLogs.md) | AKS clusters should collect platform diagnostic logs to monitor the state of workloads. | Important | Error
[Azure.Automation.PlatformLogs](Azure.Automation.PlatformLogs.md) | Ensure automation account platform diagnostic logs are enabled. | Important | Error
[Azure.Monitor.ServiceHealth](Azure.Monitor.ServiceHealth.md) | Configure Service Health alerts to notify administrators. | Important | Error
[Azure.VM.Agent](Azure.VM.Agent.md) | Ensure the VM agent is provisioned automatically. | Important | Error
[Azure.VM.MigrateAMA](Azure.VM.MigrateAMA.md) | Use Azure Monitor Agent as replacement for Log Analytics Agent. | Important | Error
[Azure.VMSS.MigrateAMA](Azure.VMSS.MigrateAMA.md) | Use Azure Monitor Agent as replacement for Log Analytics Agent. | Important | Error

### OE:04 Continuous integration

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ACR.Name](Azure.ACR.Name.md) | Container registry names should meet naming requirements. | Awareness | Error
[Azure.AKS.Name](Azure.AKS.Name.md) | Azure Kubernetes Service (AKS) cluster names should meet naming requirements. | Awareness | Error
[Azure.APIM.Name](Azure.APIM.Name.md) | API Management service names should meet naming requirements. | Awareness | Error
[Azure.NIC.Name](Azure.NIC.Name.md) | Network Interface (NIC) names should meet naming requirements. | Awareness | Error
[Azure.PublicIP.Name](Azure.PublicIP.Name.md) | Public IP names should meet naming requirements. | Awareness | Error
[Azure.Storage.Name](Azure.Storage.Name.md) | Storage Account names should meet naming requirements. | Awareness | Error
[Azure.VNET.Name](Azure.VNET.Name.md) | Virtual Network (VNET) names should meet naming requirements. | Awareness | Error
[Azure.VNG.ConnectionName](Azure.VNG.ConnectionName.md) | Virtual Network Gateway (VNG) connection names should meet naming requirements. | Awareness | Error
[Azure.VNG.Name](Azure.VNG.Name.md) | Virtual Network Gateway (VNG) names should meet naming requirements. | Awareness | Error

### OE:04 Tools and processes

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.APIM.ProductDescriptors](Azure.APIM.ProductDescriptors.md) | API Management products should have a display name and description. | Awareness | Warning

### OE:05 Infrastructure as code

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.Template.TemplateFile](Azure.Template.TemplateFile.md) | Use ARM template files that are valid. | Important | Error
[Azure.Template.ValidSecretRef](Azure.Template.ValidSecretRef.md) | Use a valid secret reference within parameter files. | Awareness | Error

### OE:07 Monitoring system

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.VM.AMA](Azure.VM.AMA.md) | Use Azure Monitor Agent for collecting monitoring data from VMs. | Important | Error
[Azure.VMSS.AMA](Azure.VMSS.AMA.md) | Use Azure Monitor Agent for collecting monitoring data from VM scale sets. | Important | Error

### Principles

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.NSG.Associated](Azure.NSG.Associated.md) | Network Security Groups (NSGs) should be associated to a subnet or network interface. | Awareness | Error

### Release engineering

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.Template.DebugDeployment](Azure.Template.DebugDeployment.md) | Use default deployment detail level for nested deployments. | Awareness | Error
[Azure.Template.DefineParameters](Azure.Template.DefineParameters.md) | Each Azure Resource Manager (ARM) template file should contain a minimal number of parameters. | Awareness | Error
[Azure.Template.LocationType](Azure.Template.LocationType.md) | Location parameters should use a string value. | Important | Error
[Azure.Template.MetadataLink](Azure.Template.MetadataLink.md) | Configure a metadata link for each parameter file. | Important | Error
[Azure.Template.ParameterDataTypes](Azure.Template.ParameterDataTypes.md) | Set the parameter default value to a value of the same type. | Important | Error
[Azure.Template.ParameterMetadata](Azure.Template.ParameterMetadata.md) | Set metadata descriptions in Azure Resource Manager (ARM) template for each parameter. | Awareness | Error
[Azure.Template.ParameterMinMaxValue](Azure.Template.ParameterMinMaxValue.md) | Template parameters minValue and maxValue constraints must be valid. | Important | Error
[Azure.Template.ResourceLocation](Azure.Template.ResourceLocation.md) | Template resource location should be an expression or global. | Awareness | Error
[Azure.Template.Resources](Azure.Template.Resources.md) | Each Azure Resource Manager (ARM) template file should deploy at least one resource. | Awareness | Error
[Azure.Template.UseLocationParameter](Azure.Template.UseLocationParameter.md) | Template should reference a location parameter to specify resource location. | Awareness | Warning
[Azure.Template.UseParameters](Azure.Template.UseParameters.md) | Each Azure Resource Manager (ARM) template parameter should be used or removed from template files. | Awareness | Error
[Azure.Template.UseVariables](Azure.Template.UseVariables.md) | Each Azure Resource Manager (ARM) template variable should be used or removed from template files. | Awareness | Error

### Repeatable infrastructure

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.APIM.MinAPIVersion](Azure.APIM.MinAPIVersion.md) | API Management instances should limit control plane API calls to API Management with version '2021-08-01' or newer. | Important | Error
[Azure.AppConfig.Name](Azure.AppConfig.Name.md) | App Configuration store names should meet naming requirements. | Awareness | Error
[Azure.AppGw.Name](Azure.AppGw.Name.md) | Application Gateways should meet naming requirements. | Awareness | Error
[Azure.AppInsights.Name](Azure.AppInsights.Name.md) | Azure Application Insights resources names should meet naming requirements. | Awareness | Error
[Azure.Arc.Server.MaintenanceConfig](Azure.Arc.Server.MaintenanceConfig.md) | Use a maintenance configuration for Arc-enabled servers. | Important | Error
[Azure.ASG.Name](Azure.ASG.Name.md) | Application Security Group (ASG) names should meet naming requirements. | Awareness | Error
[Azure.Bastion.Name](Azure.Bastion.Name.md) | Bastion hosts should meet naming requirements. | Awareness | Error
[Azure.CDN.EndpointName](Azure.CDN.EndpointName.md) | Azure CDN Endpoint names should meet naming requirements. | Awareness | Error
[Azure.ContainerApp.APIVersion](Azure.ContainerApp.APIVersion.md) | Migrate from retired API version to a supported version. | Important | Error
[Azure.ContainerApp.Name](Azure.ContainerApp.Name.md) | Container Apps should meet naming requirements. | Awareness | Error
[Azure.Cosmos.AccountName](Azure.Cosmos.AccountName.md) | Cosmos DB account names should meet naming requirements. | Awareness | Error
[Azure.Deployment.Name](Azure.Deployment.Name.md) | Nested deployments should meet naming requirements of deployments. | Awareness | Error
[Azure.Firewall.Name](Azure.Firewall.Name.md) | Firewall names should meet naming requirements. | Awareness | Error
[Azure.Firewall.PolicyName](Azure.Firewall.PolicyName.md) | Firewall policy names should meet naming requirements. | Awareness | Error
[Azure.FrontDoor.Name](Azure.FrontDoor.Name.md) | Front Door names should meet naming requirements. | Awareness | Error
[Azure.FrontDoor.WAF.Name](Azure.FrontDoor.WAF.Name.md) | Front Door WAF policy names should meet naming requirements. | Awareness | Error
[Azure.Identity.UserAssignedName](Azure.Identity.UserAssignedName.md) | Managed Identity names should meet naming requirements. | Awareness | Error
[Azure.KeyVault.KeyName](Azure.KeyVault.KeyName.md) | Key Vault Key names should meet naming requirements. | Awareness | Error
[Azure.KeyVault.Name](Azure.KeyVault.Name.md) | Key Vault names should meet naming requirements. | Awareness | Error
[Azure.KeyVault.SecretName](Azure.KeyVault.SecretName.md) | Key Vault Secret names should meet naming requirements. | Awareness | Error
[Azure.LB.Name](Azure.LB.Name.md) | Load Balancer names should meet naming requirements. | Awareness | Error
[Azure.MariaDB.DatabaseName](Azure.MariaDB.DatabaseName.md) | Azure Database for MariaDB databases should meet naming requirements. | Awareness | Error
[Azure.MariaDB.FirewallRuleName](Azure.MariaDB.FirewallRuleName.md) | Azure Database for MariaDB firewall rules should meet naming requirements. | Awareness | Error
[Azure.MariaDB.ServerName](Azure.MariaDB.ServerName.md) | Azure Database for MariaDB servers should meet naming requirements. | Awareness | Error
[Azure.MariaDB.VNETRuleName](Azure.MariaDB.VNETRuleName.md) | Azure Database for MariaDB VNET rules should meet naming requirements. | Awareness | Error
[Azure.MySQL.ServerName](Azure.MySQL.ServerName.md) | Azure MySQL DB server names should meet naming requirements. | Awareness | Error
[Azure.NSG.AKSRules](Azure.NSG.AKSRules.md) | AKS Network Security Group (NSG) should not have custom rules. | Awareness | Error
[Azure.NSG.Name](Azure.NSG.Name.md) | Network Security Group (NSG) names should meet naming requirements. | Awareness | Error
[Azure.Policy.AssignmentAssignedBy](Azure.Policy.AssignmentAssignedBy.md) | Policy assignments should use assignedBy metadata. | Awareness | Error
[Azure.Policy.AssignmentDescriptors](Azure.Policy.AssignmentDescriptors.md) | Policy assignments should use a display name and description. | Awareness | Error
[Azure.Policy.Descriptors](Azure.Policy.Descriptors.md) | Policy and initiative definitions should use a display name, description, and category. | Awareness | Error
[Azure.Policy.ExemptionDescriptors](Azure.Policy.ExemptionDescriptors.md) | Policy exemptions should use a display name and description. | Awareness | Error
[Azure.Policy.WaiverExpiry](Azure.Policy.WaiverExpiry.md) | Configure policy waiver exemptions to expire. | Awareness | Error
[Azure.PostgreSQL.ServerName](Azure.PostgreSQL.ServerName.md) | Azure PostgreSQL DB server names should meet naming requirements. | Awareness | Error
[Azure.PrivateEndpoint.Name](Azure.PrivateEndpoint.Name.md) | Private Endpoint names should meet naming requirements. | Awareness | Error
[Azure.PublicIP.DNSLabel](Azure.PublicIP.DNSLabel.md) | Public IP domain name labels should meet naming requirements. | Awareness | Error
[Azure.PublicIP.MigrateStandard](Azure.PublicIP.MigrateStandard.md) | Use the Standard SKU for Public IP addresses as the Basic SKU will be retired. | Important | Error
[Azure.ResourceGroup.Name](Azure.ResourceGroup.Name.md) | Resource Group names should meet naming requirements. | Awareness | Error
[Azure.Route.Name](Azure.Route.Name.md) | Route table names should meet naming requirements. | Awareness | Error
[Azure.RSV.Name](Azure.RSV.Name.md) | Recovery Services vaults should meet naming requirements. | Awareness | Error
[Azure.Search.Name](Azure.Search.Name.md) | Azure Cognitive Search service names should meet naming requirements. | Awareness | Error
[Azure.SignalR.Name](Azure.SignalR.Name.md) | SignalR service instance names should meet naming requirements. | Awareness | Error
[Azure.SQL.DBName](Azure.SQL.DBName.md) | Azure SQL Database names should meet naming requirements. | Awareness | Error
[Azure.SQL.FGName](Azure.SQL.FGName.md) | Azure SQL failover group names should meet naming requirements. | Awareness | Error
[Azure.SQL.ServerName](Azure.SQL.ServerName.md) | Azure SQL logical server names should meet naming requirements. | Awareness | Error
[Azure.SQLMI.Name](Azure.SQLMI.Name.md) | SQL Managed Instance names should meet naming requirements. | Awareness | Error
[Azure.Template.ExpressionLength](Azure.Template.ExpressionLength.md) | Template expressions should not exceed the maximum length. | Awareness | Error
[Azure.Template.ParameterFile](Azure.Template.ParameterFile.md) | Use ARM template parameter files that are valid. | Important | Error
[Azure.Template.ParameterScheme](Azure.Template.ParameterScheme.md) | Use an Azure template parameter file schema with the https scheme. | Awareness | Error
[Azure.Template.ParameterStrongType](Azure.Template.ParameterStrongType.md) | Set the parameter value to a value that matches the specified strong type. | Awareness | Error
[Azure.Template.ParameterValue](Azure.Template.ParameterValue.md) | Specify a value for each parameter in template parameter files. | Awareness | Error
[Azure.Template.TemplateSchema](Azure.Template.TemplateSchema.md) | Use a more recent version of the Azure template schema. | Awareness | Error
[Azure.Template.TemplateScheme](Azure.Template.TemplateScheme.md) | Use an Azure template file schema with the https scheme. | Awareness | Error
[Azure.Template.UseComments](Azure.Template.UseComments.md) | Use comments for each resource in ARM template to communicate purpose. | Awareness | Information
[Azure.Template.UseDescriptions](Azure.Template.UseDescriptions.md) | Use descriptions for each resource in generated template(bicep, psarm, AzOps) to communicate purpose. | Awareness | Information
[Azure.VM.ASName](Azure.VM.ASName.md) | Availability Set names should meet naming requirements. | Awareness | Error
[Azure.VM.ComputerName](Azure.VM.ComputerName.md) | Virtual Machine (VM) computer name should meet naming requirements. | Awareness | Error
[Azure.VM.DiskName](Azure.VM.DiskName.md) | Managed Disk names should meet naming requirements. | Awareness | Error
[Azure.VM.MaintenanceConfig](Azure.VM.MaintenanceConfig.md) | Use a maintenance configuration for virtual machines. | Important | Error
[Azure.VM.Name](Azure.VM.Name.md) | Virtual Machine (VM) names should meet naming requirements. | Awareness | Error
[Azure.VM.PPGName](Azure.VM.PPGName.md) | Proximity Placement Group (PPG) names should meet naming requirements. | Awareness | Error
[Azure.VMSS.ComputerName](Azure.VMSS.ComputerName.md) | Virtual Machine Scale Set (VMSS) computer name should meet naming requirements. | Awareness | Error
[Azure.VMSS.Name](Azure.VMSS.Name.md) | Virtual Machine Scale Set (VMSS) names should meet naming requirements. | Awareness | Error
[Azure.VNET.SubnetName](Azure.VNET.SubnetName.md) | Subnet names should meet naming requirements. | Awareness | Error
[Azure.vWAN.Name](Azure.vWAN.Name.md) | Virtual WAN (vWAN) names should meet naming requirements. | Awareness | Error

### Tagging and resource naming

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.DNSPrefix](Azure.AKS.DNSPrefix.md) | Azure Kubernetes Service (AKS) cluster DNS prefix should meet naming requirements. | Awareness | Error

## Performance Efficiency

### Application capacity

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AppService.MinPlan](Azure.AppService.MinPlan.md) | Use at least a Standard App Service Plan. | Important | Error
[Azure.Redis.MaxMemoryReserved](Azure.Redis.MaxMemoryReserved.md) | Configure maxmemory-reserved to reserve memory for non-cache operations. | Important | Error
[Azure.Redis.MinSKU](Azure.Redis.MinSKU.md) | Use Azure Cache for Redis instances of at least Standard C1. | Important | Error
[Azure.Search.SKU](Azure.Search.SKU.md) | Use the basic and standard tiers for entry level workloads. | Critical | Error

### Application design

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AppService.ARRAffinity](Azure.AppService.ARRAffinity.md) | Disable client affinity for stateless services. | Awareness | Error
[Azure.AppService.HTTP2](Azure.AppService.HTTP2.md) | Use HTTP/2 instead of HTTP/1.x to improve protocol efficiency. | Awareness | Error

### Application scalability

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.PoolScaleSet](Azure.AKS.PoolScaleSet.md) | Deploy AKS clusters with nodes pools based on VM scale sets. | Important | Error
[Azure.AKS.StandardLB](Azure.AKS.StandardLB.md) | Azure Kubernetes Clusters (AKS) should use a Standard load balancer SKU. | Important | Error

### Design for performance

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.VM.SQLServerDisk](Azure.VM.SQLServerDisk.md) | Use Premium SSD disks or greater for data and log files for production SQL Server workloads. | Important | Error

### Design for performance efficiency

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ContainerApp.DisableAffinity](Azure.ContainerApp.DisableAffinity.md) | Disable session affinity to prevent unbalanced distribution. | Important | Error

### PE:03 Selecting services

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.Databricks.SKU](Azure.Databricks.SKU.md) | Ensure Databricks workspaces are non-trial SKUs for production workloads. | Critical | Error

### PE:05 Scaling and partitioning

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.AutoScaling](Azure.AKS.AutoScaling.md) | Use autoscaling to scale clusters based on workload requirements. | Important | Error
[Azure.AKS.NodeMinPods](Azure.AKS.NodeMinPods.md) | Azure Kubernetes Cluster (AKS) nodes should use a minimum number of pods. | Important | Error

### PE:08 Data performance

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.FrontDoor.UseCaching](Azure.FrontDoor.UseCaching.md) | Use caching to reduce retrieving contents from origins. | Important | Error

### Performance

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.VM.AcceleratedNetworking](Azure.VM.AcceleratedNetworking.md) | Use accelerated networking for supported operating systems and VM types. | Important | Error
[Azure.VM.DiskCaching](Azure.VM.DiskCaching.md) | Check disk caching is configured correctly for the workload. | Important | Error

### Performance efficiency checklist

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.EphemeralOSDisk](Azure.AKS.EphemeralOSDisk.md) | AKS clusters should use ephemeral OS disks which can provide lower read/write latency, along with faster node scaling and cluster upgrades. | Important | Warning
[Azure.CDN.UseFrontDoor](Azure.CDN.UseFrontDoor.md) | Use Azure Front Door Standard or Premium SKU to improve the performance of web pages with dynamic content and overall capabilities. | Important | Error

## Reliability

### Application design

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AppService.AlwaysOn](Azure.AppService.AlwaysOn.md) | Configure Always On for App Service apps. | Important | Error
[Azure.Search.IndexSLA](Azure.Search.IndexSLA.md) | Use a minimum of 3 replicas to receive an SLA for query and index updates. | Important | Error
[Azure.Search.QuerySLA](Azure.Search.QuerySLA.md) | Use a minimum of 2 replicas to receive an SLA for index queries. | Important | Error

### Availability

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.VM.ASAlignment](Azure.VM.ASAlignment.md) | Use availability sets aligned with managed disks fault domains. | Important | Error
[Azure.VM.Standalone](Azure.VM.Standalone.md) | Use VM features to increase reliability and improve covered SLA for VM configurations. | Important | Error

### Best practices

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.VNET.BastionSubnet](Azure.VNET.BastionSubnet.md) | VNETs with a GatewaySubnet should have an AzureBastionSubnet to allow for out of band remote access to VMs. | Important | Error

### Data Management

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ACR.GeoReplica](Azure.ACR.GeoReplica.md) | Use geo-replicated container registries to compliment a multi-region container deployments. | Important | Error
[Azure.ACR.SoftDelete](Azure.ACR.SoftDelete.md) | Azure Container Registries should have soft delete policy enabled. | Important | Error
[Azure.AppConfig.PurgeProtect](Azure.AppConfig.PurgeProtect.md) | Consider purge protection for app configuration store to ensure store cannot be purged in the retention period. | Important | Error
[Azure.Storage.ContainerSoftDelete](Azure.Storage.ContainerSoftDelete.md) | Enable container soft delete on Storage Accounts. | Important | Error
[Azure.Storage.FileShareSoftDelete](Azure.Storage.FileShareSoftDelete.md) | Enable soft delete on Storage Accounts file shares. | Important | Error
[Azure.Storage.SoftDelete](Azure.Storage.SoftDelete.md) | Enable blob soft delete on Storage Accounts. | Important | Error

### Design

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.AvailabilityZone](Azure.AKS.AvailabilityZone.md) | AKS clusters deployed with virtual machine scale sets should use availability zones in supported regions for high availability. | Important | Error
[Azure.AKS.PoolVersion](Azure.AKS.PoolVersion.md) | AKS node pools should match Kubernetes control plane version. | Important | Error
[Azure.APIM.AvailabilityZone](Azure.APIM.AvailabilityZone.md) | API management services deployed with Premium SKU should use availability zones in supported regions for high availability. | Important | Error
[Azure.AppGw.AvailabilityZone](Azure.AppGw.AvailabilityZone.md) | Application gateways should use availability zones in supported regions for high availability. | Important | Error
[Azure.PublicIP.AvailabilityZone](Azure.PublicIP.AvailabilityZone.md) | Public IP addresses deployed with Standard SKU should use availability zones in supported regions for high availability. | Important | Error
[Azure.Redis.AvailabilityZone](Azure.Redis.AvailabilityZone.md) | Premium Redis cache should be deployed with availability zones for high availability. | Important | Error
[Azure.RedisEnterprise.Zones](Azure.RedisEnterprise.Zones.md) | Enterprise Redis cache should be zone-redundant for high availability. | Important | Error
[Azure.RSV.ReplicationAlert](Azure.RSV.ReplicationAlert.md) | Recovery Services Vaults (RSV) without replication alerts configured may be at risk. | Important | Error
[Azure.RSV.StorageType](Azure.RSV.StorageType.md) | Recovery Services Vaults (RSV) not using geo-replicated storage (GRS) may be at risk. | Important | Error
[Azure.VNG.ERAvailabilityZoneSKU](Azure.VNG.ERAvailabilityZoneSKU.md) | Use availability zone SKU for virtual network gateways deployed with ExpressRoute gateway type. | Important | Error

### Health modeling

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AppService.WebProbe](Azure.AppService.WebProbe.md) | Configure and enable instance health probes. | Important | Error
[Azure.AppService.WebProbePath](Azure.AppService.WebProbePath.md) | Configure a dedicated path for health probe requests. | Important | Error
[Azure.FrontDoor.Probe](Azure.FrontDoor.Probe.md) | Use health probes to check the health of each backend. | Important | Error
[Azure.FrontDoor.ProbeMethod](Azure.FrontDoor.ProbeMethod.md) | Configure health probes to use HEAD requests to reduce performance overhead. | Important | Error
[Azure.FrontDoor.ProbePath](Azure.FrontDoor.ProbePath.md) | Configure a dedicated path for health probe requests. | Important | Error

### Load balancing and failover

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AppGw.MinInstance](Azure.AppGw.MinInstance.md) | Application Gateways should use a minimum of two instances. | Important | Error
[Azure.VM.ASMinMembers](Azure.VM.ASMinMembers.md) | Availability sets should be deployed with at least two virtual machines (VMs). | Important | Error

### RE:01 Simplicity and efficiency

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.VM.UseManagedDisks](Azure.VM.UseManagedDisks.md) | Virtual machines (VMs) should use managed disks. | Important | Error

### RE:04 Target metrics

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.Version](Azure.AKS.Version.md) | AKS control plane and nodes pools should use a current stable release. | Important | Error
[Azure.LB.StandardSKU](Azure.LB.StandardSKU.md) | Load balancers should be deployed with Standard SKU for production workloads. | Important | Error

### RE:05 Redundancy

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.MinNodeCount](Azure.AKS.MinNodeCount.md) | AKS clusters should have minimum number of system nodes for failover and updates. | Important | Error
[Azure.AKS.MinUserPoolNodes](Azure.AKS.MinUserPoolNodes.md) | User node pools in an AKS cluster should have a minimum number of nodes for failover and updates. | Important | Error
[Azure.AppConfig.GeoReplica](Azure.AppConfig.GeoReplica.md) | Replicate app configuration store across all points of presence for an application. | Important | Error
[Azure.LB.Probe](Azure.LB.Probe.md) | Use a specific probe for web protocols. | Important | Error
[Azure.MySQL.UseFlexible](Azure.MySQL.UseFlexible.md) | Use Azure Database for MySQL Flexible Server deployment model. | Important | Warning
[Azure.TrafficManager.Endpoints](Azure.TrafficManager.Endpoints.md) | Traffic Manager should use at lest two enabled endpoints. | Important | Error
[Azure.VNG.VPNActiveActive](Azure.VNG.VPNActiveActive.md) | Use VPN gateways configured to operate in an Active-Active configuration to reduce connectivity downtime. | Important | Error
[Azure.VNG.VPNAvailabilityZoneSKU](Azure.VNG.VPNAvailabilityZoneSKU.md) | Use availability zone SKU for virtual network gateways deployed with VPN gateway type. | Important | Error

### RE:05 Regions and availability zones

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.LB.AvailabilityZone](Azure.LB.AvailabilityZone.md) | Load balancers deployed with Standard SKU should be zone-redundant for high availability. | Important | Error

### RE:07 Self-preservation

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.KeyVault.PurgeProtect](Azure.KeyVault.PurgeProtect.md) | Enable Purge Protection on Key Vaults to prevent early purge of vaults and vault items. | Important | Error
[Azure.KeyVault.SoftDelete](Azure.KeyVault.SoftDelete.md) | Enable Soft Delete on Key Vaults to protect vaults and vault items from accidental deletion. | Important | Error

### Reliability design principles

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ContainerApp.Storage](Azure.ContainerApp.Storage.md) | Use of Azure Files volume mounts to persistent storage container data. | Awareness | Error

### Requirements

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ACR.MinSku](Azure.ACR.MinSku.md) | ACR should use the Premium or Standard SKU for production deployments. | Important | Error
[Azure.ADX.SLA](Azure.ADX.SLA.md) | Use SKUs that include an SLA when configuring Azure Data Explorer (ADX) clusters. | Important | Error
[Azure.AKS.UptimeSLA](Azure.AKS.UptimeSLA.md) | AKS clusters should have Uptime SLA enabled for a financially backed SLA. | Important | Error
[Azure.AppConfig.SKU](Azure.AppConfig.SKU.md) | App Configuration should use a minimum size of Standard. | Important | Error
[Azure.PublicIP.StandardSKU](Azure.PublicIP.StandardSKU.md) | Public IP addresses should be deployed with Standard SKU for production workloads. | Important | Error
[Azure.Redis.Version](Azure.Redis.Version.md) | Azure Cache for Redis should use the latest supported version of Redis. | Important | Error
[Azure.SignalR.SLA](Azure.SignalR.SLA.md) | Use SKUs that include an SLA when configuring SignalR Services. | Important | Error
[Azure.Storage.UseReplication](Azure.Storage.UseReplication.md) | Storage Accounts not using geo-replicated storage (GRS) may be at risk. | Important | Error
[Azure.WebPubSub.SLA](Azure.WebPubSub.SLA.md) | Use SKUs that include an SLA when configuring Web PubSub Services. | Important | Error

### Resiliency and dependencies

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.APIM.MultiRegion](Azure.APIM.MultiRegion.md) | API Management instances should use multi-region deployment to improve service availability. | Important | Error
[Azure.APIM.MultiRegionGateway](Azure.APIM.MultiRegionGateway.md) | API Management instances should have multi-region deployment gateways enabled. | Important | Error
[Azure.AppService.PlanInstanceCount](Azure.AppService.PlanInstanceCount.md) | App Service Plan should use a minimum number of instances for failover. | Important | Error
[Azure.VNET.LocalDNS](Azure.VNET.LocalDNS.md) | Virtual networks (VNETs) should use DNS servers deployed within the same Azure region. | Important | Error
[Azure.VNET.SingleDNS](Azure.VNET.SingleDNS.md) | Virtual networks (VNETs) should have at least two DNS servers assigned. | Important | Error

### Resource deployment

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.Template.LocationDefault](Azure.Template.LocationDefault.md) | Set the default value for the location parameter within an ARM template to resource group location. | Awareness | Error

### Scalability

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.CNISubnetSize](Azure.AKS.CNISubnetSize.md) | AKS clusters using Azure CNI should use large subnets to reduce IP exhaustion issues. | Important | Error

### Target and non-functional requirements

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.MariaDB.GeoRedundantBackup](Azure.MariaDB.GeoRedundantBackup.md) | Azure Database for MariaDB should store backups in a geo-redundant storage. | Important | Error
[Azure.MySQL.GeoRedundantBackup](Azure.MySQL.GeoRedundantBackup.md) | Azure Database for MySQL should store backups in a geo-redundant storage. | Important | Error
[Azure.PostgreSQL.GeoRedundantBackup](Azure.PostgreSQL.GeoRedundantBackup.md) | Azure Database for PostgreSQL should store backups in a geo-redundant storage. | Important | Error

## Security

### Application endpoints

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ACR.Firewall](Azure.ACR.Firewall.md) | Limit network access of container registries to only trusted clients. | Important | Error
[Azure.AKS.HttpAppRouting](Azure.AKS.HttpAppRouting.md) | Disable HTTP application routing add-on in AKS clusters. | Important | Error
[Azure.AppGw.UseWAF](Azure.AppGw.UseWAF.md) | Internet accessible Application Gateways should use protect endpoints with WAF. | Critical | Error
[Azure.Cognitive.PublicAccess](Azure.Cognitive.PublicAccess.md) | Restrict access of Cognitive Services accounts to authorized virtual networks. | Important | Error
[Azure.ContainerApp.PublicAccess](Azure.ContainerApp.PublicAccess.md) | Ensure public network access for Container Apps environment is disabled. | Important | Error
[Azure.FrontDoor.UseWAF](Azure.FrontDoor.UseWAF.md) | Enable Web Application Firewall (WAF) policies on each Front Door endpoint. | Critical | Error
[Azure.FrontDoor.WAF.Enabled](Azure.FrontDoor.WAF.Enabled.md) | Front Door Web Application Firewall (WAF) policy must be enabled to protect back end resources. | Critical | Error
[Azure.KeyVault.Firewall](Azure.KeyVault.Firewall.md) | Key Vault should only accept explicitly allowed traffic. | Important | Error
[Azure.Storage.Firewall](Azure.Storage.Firewall.md) | Storage Accounts should only accept explicitly allowed traffic. | Important | Error

### Authentication

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.Automation.ManagedIdentity](Azure.Automation.ManagedIdentity.md) | Ensure Managed Identity is used for authentication. | Important | Error
[Azure.Cognitive.DisableLocalAuth](Azure.Cognitive.DisableLocalAuth.md) | Authenticate requests to Cognitive Services with Azure AD identities. | Important | Error
[Azure.Cosmos.DisableMetadataWrite](Azure.Cosmos.DisableMetadataWrite.md) | Use Azure AD identities for management place operations in Azure Cosmos DB. | Important | Error
[Azure.FrontDoor.ManagedIdentity](Azure.FrontDoor.ManagedIdentity.md) | Ensure Front Door uses a managed identity to authorize access to Azure resources. | Important | Error
[Azure.ML.DisableLocalAuth](Azure.ML.DisableLocalAuth.md) | Azure Machine Learning compute resources should have local authentication methods disabled. | Critical | Error
[Azure.MySQL.AAD](Azure.MySQL.AAD.md) | Use Azure Active Directory (AAD) authentication with Azure Database for MySQL databases. | Critical | Error
[Azure.Search.ManagedIdentity](Azure.Search.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important | Error
[Azure.ServiceBus.DisableLocalAuth](Azure.ServiceBus.DisableLocalAuth.md) | Authenticate Service Bus publishers and consumers with Azure AD identities. | Important | Error
[Azure.SignalR.ManagedIdentity](Azure.SignalR.ManagedIdentity.md) | Configure SignalR Services to use managed identities to access Azure resources securely. | Important | Error
[Azure.SQL.AAD](Azure.SQL.AAD.md) | Use Azure Active Directory (AAD) authentication with Azure SQL databases. | Critical | Error
[Azure.SQLMI.AAD](Azure.SQLMI.AAD.md) | Use Azure Active Directory (AAD) authentication with Azure SQL Managed Instance. | Critical | Error
[Azure.SQLMI.ManagedIdentity](Azure.SQLMI.ManagedIdentity.md) | Ensure managed identity is used to allow support for Azure AD authentication. | Important | Error
[Azure.WebPubSub.ManagedIdentity](Azure.WebPubSub.ManagedIdentity.md) | Configure Web PubSub Services to use managed identities to access Azure resources securely. | Important | Error

### Authorization

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.LocalAccounts](Azure.AKS.LocalAccounts.md) | Enforce named user accounts with RBAC assigned permissions. | Important | Error

### Azure resources

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ACR.ContainerScan](Azure.ACR.ContainerScan.md) | Enable vulnerability scanning for container images. | Critical | Error
[Azure.ACR.Quarantine](Azure.ACR.Quarantine.md) | Enable container image quarantine, scan, and mark images as verified. | Important | Error
[Azure.AKS.DefenderProfile](Azure.AKS.DefenderProfile.md) | Enable the Defender profile with Azure Kubernetes Service (AKS) cluster. | Important | Error
[Azure.Defender.Containers](Azure.Defender.Containers.md) | Enable Microsoft Defender for Containers. | Critical | Error

### Connectivity

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ML.ComputeVnet](Azure.ML.ComputeVnet.md) | Azure Machine Learning Computes should be hosted in a virtual network (VNet). | Critical | Error
[Azure.ML.PublicAccess](Azure.ML.PublicAccess.md) | Disable public network access from a Azure Machine Learning workspace. | Critical | Error
[Azure.Redis.FirewallIPRange](Azure.Redis.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses for the Redis cache. | Critical | Error
[Azure.Redis.FirewallRuleCount](Azure.Redis.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules for the Redis cache. | Awareness | Error
[Azure.Redis.PublicNetworkAccess](Azure.Redis.PublicNetworkAccess.md) | Redis cache should disable public network access. | Critical | Error

### Data flow

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.Cognitive.PrivateEndpoints](Azure.Cognitive.PrivateEndpoints.md) | Use Private Endpoints to access Cognitive Services accounts. | Important | Error

### Data protection

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ACR.ContentTrust](Azure.ACR.ContentTrust.md) | Use container images signed by a trusted image publisher. | Important | Error
[Azure.APIM.EncryptValues](Azure.APIM.EncryptValues.md) | Encrypt all API Management named values with Key Vault secrets. | Important | Error
[Azure.APIM.HTTPEndpoint](Azure.APIM.HTTPEndpoint.md) | Enforce HTTPS for communication to API clients. | Important | Error
[Azure.AppService.UseHTTPS](Azure.AppService.UseHTTPS.md) | Azure App Service apps should only accept encrypted connections. | Important | Error
[Azure.AppService.WebSecureFtp](Azure.AppService.WebSecureFtp.md) | Web apps should disable insecure FTP and configure SFTP when required. | Important | Error
[Azure.Automation.EncryptVariables](Azure.Automation.EncryptVariables.md) | Azure Automation variables should be encrypted. | Important | Error
[Azure.CDN.HTTP](Azure.CDN.HTTP.md) | Enforce HTTPS for client connections. | Important | Error
[Azure.Defender.AppServices](Azure.Defender.AppServices.md) | Enable Microsoft Defender for App Service. | Critical | Error
[Azure.MariaDB.UseSSL](Azure.MariaDB.UseSSL.md) | Azure Database for MariaDB servers should only accept encrypted connections. | Critical | Error
[Azure.MySQL.UseSSL](Azure.MySQL.UseSSL.md) | Enforce encrypted MySQL connections. | Critical | Error
[Azure.PostgreSQL.UseSSL](Azure.PostgreSQL.UseSSL.md) | Enforce encrypted PostgreSQL connections. | Critical | Error
[Azure.SQL.TDE](Azure.SQL.TDE.md) | Use Transparent Data Encryption (TDE) with Azure SQL Database. | Critical | Error
[Azure.VM.ADE](Azure.VM.ADE.md) | Use Azure Disk Encryption (ADE). | Important | Error

### Deployment

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AppService.NETVersion](Azure.AppService.NETVersion.md) | Configure applications to use newer .NET versions. | Important | Error
[Azure.AppService.PHPVersion](Azure.AppService.PHPVersion.md) | Configure applications to use newer PHP runtime versions. | Important | Error

### Design

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.APIM.CORSPolicy](Azure.APIM.CORSPolicy.md) | Avoid using wildcard for any configuration option in CORS policies. | Important | Error
[Azure.APIM.PolicyBase](Azure.APIM.PolicyBase.md) | Base element for any policy element in a section should be configured. | Important | Error

### Encryption

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ADX.DiskEncryption](Azure.ADX.DiskEncryption.md) | Use disk encryption for Azure Data Explorer (ADX) clusters. | Important | Error
[Azure.APIM.Ciphers](Azure.APIM.Ciphers.md) | API Management should not accept weak or deprecated ciphers for client or backend communication. | Critical | Error
[Azure.APIM.HTTPBackend](Azure.APIM.HTTPBackend.md) | Use HTTPS for communication to backend services. | Critical | Error
[Azure.APIM.Protocols](Azure.APIM.Protocols.md) | API Management should only accept a minimum of TLS 1.2 for client and backend communication. | Critical | Error
[Azure.AppService.MinTLS](Azure.AppService.MinTLS.md) | App Service should reject TLS versions older than 1.2. | Critical | Error
[Azure.CDN.MinTLS](Azure.CDN.MinTLS.md) | Azure CDN endpoints should reject TLS versions older than 1.2. | Important | Error
[Azure.FrontDoor.MinTLS](Azure.FrontDoor.MinTLS.md) | Front Door Classic instances should reject TLS versions older than 1.2. | Critical | Error
[Azure.IoTHub.MinTLS](Azure.IoTHub.MinTLS.md) | IoT Hubs should reject TLS versions older than 1.2. | Critical | Error
[Azure.MariaDB.MinTLS](Azure.MariaDB.MinTLS.md) | Azure Database for MariaDB servers should reject TLS versions older than 1.2. | Critical | Error
[Azure.MySQL.MinTLS](Azure.MySQL.MinTLS.md) | MySQL DB servers should reject TLS versions older than 1.2. | Critical | Error
[Azure.PostgreSQL.MinTLS](Azure.PostgreSQL.MinTLS.md) | PostgreSQL DB servers should reject TLS versions older than 1.2. | Critical | Error
[Azure.Redis.NonSslPort](Azure.Redis.NonSslPort.md) | Azure Cache for Redis should only accept secure connections. | Critical | Error
[Azure.SQL.MinTLS](Azure.SQL.MinTLS.md) | Azure SQL Database servers should reject TLS versions older than 1.2. | Critical | Error

### Identity and access management

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ACR.AnonymousAccess](Azure.ACR.AnonymousAccess.md) | Disable anonymous pull access. | Important | Error
[Azure.AKS.AzureRBAC](Azure.AKS.AzureRBAC.md) | Use Azure RBAC for Kubernetes Authorization with AKS clusters. | Important | Error
[Azure.AKS.ManagedAAD](Azure.AKS.ManagedAAD.md) | Use AKS-managed Azure AD to simplify authorization and improve security. | Important | Error
[Azure.AKS.UseRBAC](Azure.AKS.UseRBAC.md) | Deploy AKS cluster with role-based access control (RBAC) enabled. | Important | Error
[Azure.Automation.WebHookExpiry](Azure.Automation.WebHookExpiry.md) | Do not create webhooks with an expiry time greater than 1 year (default). | Awareness | Error
[Azure.KeyVault.AccessPolicy](Azure.KeyVault.AccessPolicy.md) | Use the principal of least privilege when assigning access to Key Vault. | Important | Error
[Azure.ML.UserManagedIdentity](Azure.ML.UserManagedIdentity.md) | ML workspaces should use user-assigned managed identity, rather than the default system-assigned managed identity. | Important | Error
[Azure.MySQL.AADOnly](Azure.MySQL.AADOnly.md) | Ensure Azure AD-only authentication is enabled with Azure Database for MySQL databases. | Important | Error
[Azure.PostgreSQL.AADOnly](Azure.PostgreSQL.AADOnly.md) | Ensure Azure AD-only authentication is enabled with Azure Database for PostgreSQL databases. | Important | Error
[Azure.RBAC.CoAdministrator](Azure.RBAC.CoAdministrator.md) | Delegate access to manage Azure resources using role-based access control (RBAC). | Important | Error
[Azure.RBAC.LimitMGDelegation](Azure.RBAC.LimitMGDelegation.md) | Limit Role-Base Access Control (RBAC) inheritance from Management Groups. | Important | Error
[Azure.RBAC.LimitOwner](Azure.RBAC.LimitOwner.md) | Limit the number of subscription Owners. | Important | Error
[Azure.RBAC.PIM](Azure.RBAC.PIM.md) | Use just-in-time (JiT) activation of roles instead of persistent role assignment. | Important | Error
[Azure.RBAC.UseGroups](Azure.RBAC.UseGroups.md) | Use groups for assigning permissions instead of individual user accounts. | Important | Error
[Azure.RBAC.UseRGDelegation](Azure.RBAC.UseRGDelegation.md) | Use RBAC assignments on resource groups instead of individual resources. | Important | Error
[Azure.ServiceFabric.AAD](Azure.ServiceFabric.AAD.md) | Use Azure Active Directory (AAD) client authentication for Service Fabric clusters. | Critical | Error
[Azure.SQL.AADOnly](Azure.SQL.AADOnly.md) | Ensure Azure AD-only authentication is enabled with Azure SQL Database. | Important | Error
[Azure.SQLMI.AADOnly](Azure.SQLMI.AADOnly.md) | Ensure Azure AD-only authentication is enabled with Azure SQL Managed Instance. | Important | Error
[Azure.VM.PublicKey](Azure.VM.PublicKey.md) | Linux virtual machines should use public keys. | Important | Error
[Azure.VMSS.PublicKey](Azure.VMSS.PublicKey.md) | Use SSH keys instead of common credentials to secure virtual machine scale sets against malicious activities. | Important | Error

### Information protection

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ServiceBus.MinTLS](Azure.ServiceBus.MinTLS.md) | Enforce namespaces to require that clients send and receive data with TLS 1.2 version. | Important | Error

### Infrastructure provisioning

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.Deployment.AdminUsername](Azure.Deployment.AdminUsername.md) | Use secure parameters for sensitive resource properties. | Awareness | Error
[Azure.Deployment.OuterSecret](Azure.Deployment.OuterSecret.md) | Do not use Outer deployments when references SecureString or SecureObject parameters. | Critical | Error
[Azure.Deployment.OutputSecretValue](Azure.Deployment.OutputSecretValue.md) | Avoid outputting sensitive deployment values. | Critical | Error
[Azure.Deployment.SecureParameter](Azure.Deployment.SecureParameter.md) | Use secure parameters for any parameter that contains sensitive information. | Critical | Error
[Azure.Deployment.SecureValue](Azure.Deployment.SecureValue.md) | Use secure parameters for setting properties of resources that contain sensitive information. | Critical | Error

### Key and secret management

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.SecretStore](Azure.AKS.SecretStore.md) | Deploy AKS clusters with Secrets Store CSI Driver and store Secrets in Key Vault. | Important | Error
[Azure.AKS.SecretStoreRotation](Azure.AKS.SecretStoreRotation.md) | Enable autorotation of Secrets Store CSI Driver secrets for AKS clusters. | Important | Error
[Azure.KeyVault.AutoRotationPolicy](Azure.KeyVault.AutoRotationPolicy.md) | Key Vault keys should have auto-rotation enabled. | Important | Error

### Monitor

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.AuditLogs](Azure.AKS.AuditLogs.md) | AKS clusters should collect security-based audit logs to assess and monitor the compliance status of workloads. | Important | Error
[Azure.Automation.AuditLogs](Azure.Automation.AuditLogs.md) | Ensure automation account audit diagnostic logs are enabled. | Important | Error
[Azure.ServiceBus.AuditLogs](Azure.ServiceBus.AuditLogs.md) | Ensure namespaces audit diagnostic logs are enabled. | Important | Error

### Network security and containment

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AppGw.OWASP](Azure.AppGw.OWASP.md) | Application Gateway Web Application Firewall (WAF) should use OWASP 3.x rules. | Important | Error
[Azure.AppGw.Prevention](Azure.AppGw.Prevention.md) | Internet exposed Application Gateways should use prevention mode to protect backend resources. | Critical | Error
[Azure.AppGw.WAFEnabled](Azure.AppGw.WAFEnabled.md) | Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources. | Critical | Error
[Azure.AppGw.WAFRules](Azure.AppGw.WAFRules.md) | Application Gateway Web Application Firewall (WAF) should have all rules enabled. | Important | Error
[Azure.AppGwWAF.Enabled](Azure.AppGwWAF.Enabled.md) | Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources. | Critical | Error
[Azure.AppGwWAF.Exclusions](Azure.AppGwWAF.Exclusions.md) | Application Gateway Web Application Firewall (WAF) should have all rules enabled. | Critical | Error
[Azure.AppGwWAF.PreventionMode](Azure.AppGwWAF.PreventionMode.md) | Use protection mode in Application Gateway Web Application Firewall (WAF) policies to protect back end resources. | Critical | Error
[Azure.AppGwWAF.RuleGroups](Azure.AppGwWAF.RuleGroups.md) | Use recommended rule groups in Application Gateway Web Application Firewall (WAF) policies to protect back end resources. | Critical | Error
[Azure.ContainerApp.ExternalIngress](Azure.ContainerApp.ExternalIngress.md) | Limit inbound communication for Container Apps is limited to callers within the Container Apps Environment. | Important | Error
[Azure.ContainerApp.RestrictIngress](Azure.ContainerApp.RestrictIngress.md) | IP ingress restrictions mode should be set to allow action for all rules defined. | Important | Error
[Azure.Firewall.Mode](Azure.Firewall.Mode.md) | Deny high confidence malicious IP addresses and domains on classic managed Azure Firewalls. | Critical | Error
[Azure.Firewall.PolicyMode](Azure.Firewall.PolicyMode.md) | Deny high confidence malicious IP addresses, domains and URLs. | Critical | Error
[Azure.FrontDoor.WAF.Mode](Azure.FrontDoor.WAF.Mode.md) | Use protection mode in Front Door Web Application Firewall (WAF) policies to protect back end resources. | Critical | Error
[Azure.FrontDoorWAF.Enabled](Azure.FrontDoorWAF.Enabled.md) | Front Door Web Application Firewall (WAF) policy must be enabled to protect back end resources. | Critical | Error
[Azure.FrontDoorWAF.Exclusions](Azure.FrontDoorWAF.Exclusions.md) | Use recommended rule groups in Front Door Web Application Firewall (WAF) policies to protect back end resources. Avoid configuring rule exclusions. | Critical | Error
[Azure.FrontDoorWAF.PreventionMode](Azure.FrontDoorWAF.PreventionMode.md) | Use protection mode in Front Door Web Application Firewall (WAF) policies to protect back end resources. | Critical | Error
[Azure.FrontDoorWAF.RuleGroups](Azure.FrontDoorWAF.RuleGroups.md) | Use recommended rule groups in Front Door Web Application Firewall (WAF) policies to protect back end resources. | Critical | Error
[Azure.LogicApp.LimitHTTPTrigger](Azure.LogicApp.LimitHTTPTrigger.md) | Limit HTTP request trigger access to trusted IP addresses. | Critical | Error
[Azure.MariaDB.AllowAzureAccess](Azure.MariaDB.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important | Error
[Azure.MariaDB.FirewallIPRange](Azure.MariaDB.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important | Error
[Azure.MariaDB.FirewallRuleCount](Azure.MariaDB.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness | Error
[Azure.MySQL.AllowAzureAccess](Azure.MySQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important | Error
[Azure.MySQL.FirewallIPRange](Azure.MySQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important | Error
[Azure.MySQL.FirewallRuleCount](Azure.MySQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness | Error
[Azure.PostgreSQL.AllowAzureAccess](Azure.PostgreSQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important | Error
[Azure.PostgreSQL.FirewallIPRange](Azure.PostgreSQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses. | Important | Error
[Azure.PostgreSQL.FirewallRuleCount](Azure.PostgreSQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness | Error
[Azure.SQL.AllowAzureAccess](Azure.SQL.AllowAzureAccess.md) | Determine if access from Azure services is required. | Important | Error
[Azure.SQL.FirewallIPRange](Azure.SQL.FirewallIPRange.md) | Determine if there is an excessive number of permitted IP addresses set in the allowed IP list (CIDR range). | Important | Error
[Azure.SQL.FirewallRuleCount](Azure.SQL.FirewallRuleCount.md) | Determine if there is an excessive number of firewall rules. | Awareness | Error

### Network segmentation

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.NSG.LateralTraversal](Azure.NSG.LateralTraversal.md) | Deny outbound management connections from non-management hosts. | Important | Error
[Azure.VNET.FirewallSubnet](Azure.VNET.FirewallSubnet.md) | Use Azure Firewall to filter network traffic to and from Azure resources. | Important | Error

### Optimize

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.AzurePolicyAddOn](Azure.AKS.AzurePolicyAddOn.md) | Configure Azure Kubernetes Service (AKS) clusters to use Azure Policy Add-on for Kubernetes. | Important | Error

### Review and remediate

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ACR.ImageHealth](Azure.ACR.ImageHealth.md) | Remove container images with known vulnerabilities. | Critical | Error

### SE:01 Security baseline

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.Resource.AllowedRegions](Azure.Resource.AllowedRegions.md) | Resources should be deployed to allowed regions. | Important | Error

### SE:04 Segmentation

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.NetworkPolicy](Azure.AKS.NetworkPolicy.md) | Deploy AKS clusters with Network Policies enabled. | Important | Error

### SE:05 Identity and access management

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.ACR.AdminUser](Azure.ACR.AdminUser.md) | Use Entra ID identities instead of using the registry admin user. | Critical | Error
[Azure.ADX.ManagedIdentity](Azure.ADX.ManagedIdentity.md) | Configure Data Explorer clusters to use managed identities to access Azure resources securely. | Important | Error
[Azure.AKS.ManagedIdentity](Azure.AKS.ManagedIdentity.md) | Configure AKS clusters to use managed identities for managing cluster infrastructure. | Important | Error
[Azure.APIM.ManagedIdentity](Azure.APIM.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important | Error
[Azure.APIM.ProductApproval](Azure.APIM.ProductApproval.md) | Configure products to require approval. | Important | Error
[Azure.APIM.ProductSubscription](Azure.APIM.ProductSubscription.md) | Configure products to require a subscription. | Important | Error
[Azure.AppConfig.DisableLocalAuth](Azure.AppConfig.DisableLocalAuth.md) | Authenticate App Configuration clients with Entra ID identities. | Important | Error
[Azure.AppService.ManagedIdentity](Azure.AppService.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important | Error
[Azure.Cognitive.ManagedIdentity](Azure.Cognitive.ManagedIdentity.md) | Configure managed identities to access Azure resources. | Important | Error
[Azure.ContainerApp.ManagedIdentity](Azure.ContainerApp.ManagedIdentity.md) | Ensure managed identity is used for authentication. | Important | Error
[Azure.EventGrid.DisableLocalAuth](Azure.EventGrid.DisableLocalAuth.md) | Authenticate publishing clients with Azure AD identities. | Important | Error
[Azure.EventGrid.ManagedIdentity](Azure.EventGrid.ManagedIdentity.md) | Use managed identities to deliver Event Grid Topic events. | Important | Error
[Azure.EventHub.DisableLocalAuth](Azure.EventHub.DisableLocalAuth.md) | Authenticate Event Hub publishers and consumers with Entra ID identities. | Important | Error
[Azure.KeyVault.RBAC](Azure.KeyVault.RBAC.md) | Key Vaults should use Azure RBAC as the authorization system for the data plane. | Awareness | Warning
[Azure.PostgreSQL.AAD](Azure.PostgreSQL.AAD.md) | Use Entra ID authentication with Azure Database for PostgreSQL databases. | Critical | Error
[Azure.Storage.BlobAccessType](Azure.Storage.BlobAccessType.md) | Use containers configured with a private access type that requires authorization. | Important | Error
[Azure.Storage.BlobPublicAccess](Azure.Storage.BlobPublicAccess.md) | Storage Accounts should only accept authorized requests. | Important | Error

### SE:06 Network controls

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AKS.AuthorizedIPs](Azure.AKS.AuthorizedIPs.md) | Restrict access to API server endpoints to authorized IP addresses. | Important | Error
[Azure.Databricks.PublicAccess](Azure.Databricks.PublicAccess.md) | Azure Databricks workspaces should disable public network access. | Critical | Error
[Azure.Databricks.SecureConnectivity](Azure.Databricks.SecureConnectivity.md) | Use Databricks workspaces configured for secure cluster connectivity. | Critical | Error
[Azure.EventGrid.TopicPublicAccess](Azure.EventGrid.TopicPublicAccess.md) | Use Private Endpoints to access Event Grid topics and domains. | Important | Error
[Azure.NSG.AnyInboundSource](Azure.NSG.AnyInboundSource.md) | Network security groups (NSGs) should avoid rules that allow "any" as an inbound source. | Critical | Error
[Azure.VNET.UseNSGs](Azure.VNET.UseNSGs.md) | Virtual network (VNET) subnets should have Network Security Groups (NSGs) assigned. | Critical | Error

### SE:07 Encryption

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AppGw.SSLPolicy](Azure.AppGw.SSLPolicy.md) | Application Gateway should only accept a minimum of TLS 1.2. | Critical | Error
[Azure.AppGw.UseHTTPS](Azure.AppGw.UseHTTPS.md) | Application Gateways should only expose frontend HTTP endpoints over HTTPS. | Critical | Error
[Azure.ContainerApp.Insecure](Azure.ContainerApp.Insecure.md) | Ensure insecure inbound traffic is not permitted to the container app. | Important | Error
[Azure.EventHub.MinTLS](Azure.EventHub.MinTLS.md) | Event Hub namespaces should reject TLS versions older than 1.2. | Critical | Error
[Azure.Redis.MinTLS](Azure.Redis.MinTLS.md) | Redis Cache should reject TLS versions older than 1.2. | Critical | Error
[Azure.RedisEnterprise.MinTLS](Azure.RedisEnterprise.MinTLS.md) | Redis Cache should reject TLS versions older than 1.2. | Critical | Error
[Azure.Storage.MinTLS](Azure.Storage.MinTLS.md) | Storage Accounts should reject TLS versions older than 1.2. | Critical | Error
[Azure.Storage.SecureTransfer](Azure.Storage.SecureTransfer.md) | Storage accounts should only accept encrypted connections. | Important | Error
[Azure.TrafficManager.Protocol](Azure.TrafficManager.Protocol.md) | Monitor Traffic Manager web-based endpoints with HTTPS. | Important | Error

### SE:10 Monitoring and threat detection

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.APIM.DefenderCloud](Azure.APIM.DefenderCloud.md) | APIs published in Azure API Management should be onboarded to Microsoft Defender for APIs. | Critical | Error
[Azure.AppConfig.AuditLogs](Azure.AppConfig.AuditLogs.md) | Ensure app configuration store audit diagnostic logs are enabled. | Important | Error
[Azure.Defender.Api](Azure.Defender.Api.md) | Enable Microsoft Defender for APIs. | Critical | Error
[Azure.Defender.Storage](Azure.Defender.Storage.md) | Enable Microsoft Defender for Storage. | Critical | Error
[Azure.Defender.Storage.DataScan](Azure.Defender.Storage.DataScan.md) | Enable sensitive data threat detection in Microsoft Defender for Storage. | Critical | Error
[Azure.Defender.Storage.MalwareScan](Azure.Defender.Storage.MalwareScan.md) | Enable Malware Scanning in Microsoft Defender for Storage. | Critical | Error
[Azure.FrontDoor.Logs](Azure.FrontDoor.Logs.md) | Audit and monitor access through Azure Front Door profiles. | Important | Error
[Azure.KeyVault.Logs](Azure.KeyVault.Logs.md) | Ensure audit diagnostics logs are enabled to audit Key Vault access. | Important | Error
[Azure.Storage.Defender.DataScan](Azure.Storage.Defender.DataScan.md) | Enable sensitive data threat detection in Microsoft Defender for Storage. | Critical | Error
[Azure.Storage.Defender.MalwareScan](Azure.Storage.Defender.MalwareScan.md) | Enable Malware Scanning in Microsoft Defender for Storage. | Critical | Error
[Azure.Storage.DefenderCloud](Azure.Storage.DefenderCloud.md) | Enable Microsoft Defender for Storage for storage accounts. | Critical | Error

### Secrets

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.VM.ScriptExtensions](Azure.VM.ScriptExtensions.md) | Custom Script Extensions scripts that reference secret values must use the protectedSettings. | Important | Error
[Azure.VMSS.ScriptExtensions](Azure.VMSS.ScriptExtensions.md) | Custom Script Extensions scripts that reference secret values must use the protectedSettings. | Important | Error

### Security configuration

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.AppService.RemoteDebug](Azure.AppService.RemoteDebug.md) | Disable remote debugging on App Service apps when not in use. | Important | Error

### Security design principles

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.BV.Immutable](Azure.BV.Immutable.md) | Ensure immutability is configured to protect backup data. | Important | Error
[Azure.RSV.Immutable](Azure.RSV.Immutable.md) | Ensure immutability is configured to protect backup data. | Important | Error

### Security operations

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.Arc.Kubernetes.Defender](Azure.Arc.Kubernetes.Defender.md) | Deploy Microsoft Defender for Containers extension for Arc-enabled Kubernetes clusters. | Important | Error
[Azure.Cosmos.DefenderCloud](Azure.Cosmos.DefenderCloud.md) | Enable Microsoft Defender for Azure Cosmos DB. | Critical | Error
[Azure.Defender.Arm](Azure.Defender.Arm.md) | Enable Microsoft Defender for Azure Resource Manager (ARM). | Critical | Error
[Azure.Defender.CosmosDb](Azure.Defender.CosmosDb.md) | Enable Microsoft Defender for Azure Cosmos DB. | Critical | Error
[Azure.Defender.Cspm](Azure.Defender.Cspm.md) | Enable Microsoft Defender Cloud Security Posture Management Standard plan. | Critical | Error
[Azure.Defender.Dns](Azure.Defender.Dns.md) | Enable Microsoft Defender for DNS. | Critical | Error
[Azure.Defender.KeyVault](Azure.Defender.KeyVault.md) | Enable Microsoft Defender for Key Vault. | Critical | Error
[Azure.Defender.OssRdb](Azure.Defender.OssRdb.md) | Enable Microsoft Defender for open-source relational databases. | Critical | Error
[Azure.Defender.SQL](Azure.Defender.SQL.md) | Enable Microsoft Defender for SQL servers. | Critical | Error
[Azure.Defender.SQLOnVM](Azure.Defender.SQLOnVM.md) | Enable Microsoft Defender for SQL servers on machines. | Critical | Error
[Azure.DefenderCloud.Contact](Azure.DefenderCloud.Contact.md) | Microsoft Defender for Cloud email and phone contact details should be set. | Important | Error
[Azure.DefenderCloud.Provisioning](Azure.DefenderCloud.Provisioning.md) | Enable auto-provisioning on to improve Microsoft Defender for Cloud insights. | Important | Error
[Azure.MariaDB.DefenderCloud](Azure.MariaDB.DefenderCloud.md) | Enable Microsoft Defender for Cloud for Azure Database for MariaDB. | Important | Error
[Azure.MySQL.DefenderCloud](Azure.MySQL.DefenderCloud.md) | Enable Microsoft Defender for Cloud for Azure Database for MySQL. | Important | Error
[Azure.PostgreSQL.DefenderCloud](Azure.PostgreSQL.DefenderCloud.md) | Enable Microsoft Defender for Cloud for Azure Database for PostgreSQL. | Important | Error
[Azure.SQL.Auditing](Azure.SQL.Auditing.md) | Enable auditing for Azure SQL logical server. | Important | Error
[Azure.SQL.DefenderCloud](Azure.SQL.DefenderCloud.md) | Enable Microsoft Defender for Azure SQL logical server. | Important | Error

### Virtual Machine

Name | Synopsis | Severity | Level
---- | -------- | -------- | -----
[Azure.Defender.Servers](Azure.Defender.Servers.md) | Enable Microsoft Defender for Servers. | Critical | Error
