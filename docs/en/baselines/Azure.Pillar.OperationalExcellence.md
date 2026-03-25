---
taxonomy: Azure.WAF
pillar: Operational Excellence
export: true
moduleVersion: v1.35.0
generated: true
---

# Azure.Pillar.OperationalExcellence

Microsoft Azure Well-Architected Framework - Operational Excellence pillar specific baseline.

## Rules

The following rules are included within the `Azure.Pillar.OperationalExcellence` baseline.

This baseline includes a total of 147 rules.

Name | Synopsis | Severity | Maturity
---- | -------- | -------- | --------
[Azure.ACI.Naming](../rules/Azure.ACI.Naming.md) | Container Instance resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.ACR.Name](../rules/Azure.ACR.Name.md) | Container registry names should meet naming requirements. | Awareness | L2
[Azure.ACR.Naming](../rules/Azure.ACR.Naming.md) | Container Registry resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.AI.FoundryNaming](../rules/Azure.AI.FoundryNaming.md) | Azure AI Foundry accounts without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.AKS.ContainerInsights](../rules/Azure.AKS.ContainerInsights.md) | Enable Container insights to monitor AKS cluster workloads. | Important | -
[Azure.AKS.DNSPrefix](../rules/Azure.AKS.DNSPrefix.md) | Azure Kubernetes Service (AKS) cluster DNS prefix should meet naming requirements. | Awareness | -
[Azure.AKS.Name](../rules/Azure.AKS.Name.md) | Azure Kubernetes Service (AKS) cluster names should meet naming requirements. | Awareness | L2
[Azure.AKS.Naming](../rules/Azure.AKS.Naming.md) | AKS cluster resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.AKS.PlatformLogs](../rules/Azure.AKS.PlatformLogs.md) | AKS clusters should collect platform diagnostic logs to monitor the state of workloads. | Important | -
[Azure.AKS.SystemPoolNaming](../rules/Azure.AKS.SystemPoolNaming.md) | AKS system node pool resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.AKS.UserPoolNaming](../rules/Azure.AKS.UserPoolNaming.md) | AKS user node pool resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.APIM.APIDescriptors](../rules/Azure.APIM.APIDescriptors.md) | APIs should have a display name and description. | Awareness | -
[Azure.APIM.MinAPIVersion](../rules/Azure.APIM.MinAPIVersion.md) | API Management instances should limit control plane API calls to API Management with version '2021-08-01' or newer. | Important | -
[Azure.APIM.Name](../rules/Azure.APIM.Name.md) | API Management service names should meet naming requirements. | Awareness | -
[Azure.APIM.ProductDescriptors](../rules/Azure.APIM.ProductDescriptors.md) | API Management products should have a display name and description. | Awareness | -
[Azure.AppConfig.Name](../rules/Azure.AppConfig.Name.md) | App Configuration store names should meet naming requirements. | Awareness | -
[Azure.AppGw.MigrateV2](../rules/Azure.AppGw.MigrateV2.md) | Use a Application Gateway v2 SKU. | Important | -
[Azure.AppGw.MinSku](../rules/Azure.AppGw.MinSku.md) | Application Gateway should use a minimum instance size of Medium. | Important | -
[Azure.AppGw.Name](../rules/Azure.AppGw.Name.md) | Application Gateways should meet naming requirements. | Awareness | -
[Azure.AppInsights.Name](../rules/Azure.AppInsights.Name.md) | Azure Resource Manager (ARM) has requirements for Application Insights resource names. | Awareness | -
[Azure.AppInsights.Naming](../rules/Azure.AppInsights.Naming.md) | Application Insights resources without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.AppInsights.Workspace](../rules/Azure.AppInsights.Workspace.md) | Configure Application Insights resources to store data in a workspace. | Important | -
[Azure.ASE.MigrateV3](../rules/Azure.ASE.MigrateV3.md) | Use ASEv3 as replacement for the classic app service environment versions ASEv1 and ASEv2. | Important | -
[Azure.ASG.Name](../rules/Azure.ASG.Name.md) | Application Security Group (ASG) names should meet naming requirements. | Awareness | -
[Azure.Automation.PlatformLogs](../rules/Azure.Automation.PlatformLogs.md) | Ensure automation account platform diagnostic logs are enabled. | Important | -
[Azure.Bastion.Name](../rules/Azure.Bastion.Name.md) | Bastion hosts should meet naming requirements. | Awareness | -
[Azure.CDN.EndpointName](../rules/Azure.CDN.EndpointName.md) | Azure CDN Endpoint names should meet naming requirements. | Awareness | -
[Azure.ContainerApp.APIVersion](../rules/Azure.ContainerApp.APIVersion.md) | Migrate from retired API version to a supported version. | Important | -
[Azure.ContainerApp.EnvNaming](../rules/Azure.ContainerApp.EnvNaming.md) | Container App Environment resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.ContainerApp.JobNaming](../rules/Azure.ContainerApp.JobNaming.md) | Container App Job resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.ContainerApp.Name](../rules/Azure.ContainerApp.Name.md) | Container Apps should meet naming requirements. | Awareness | L2
[Azure.ContainerApp.Naming](../rules/Azure.ContainerApp.Naming.md) | Container App resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.Cosmos.AccountName](../rules/Azure.Cosmos.AccountName.md) | Cosmos DB account names should meet naming requirements. | Awareness | L2
[Azure.Cosmos.CassandraNaming](../rules/Azure.Cosmos.CassandraNaming.md) | Cosmos DB for Apache Cassandra account resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.Cosmos.DatabaseNaming](../rules/Azure.Cosmos.DatabaseNaming.md) | Cosmos DB database resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.Cosmos.GremlinNaming](../rules/Azure.Cosmos.GremlinNaming.md) | Cosmos DB for Apache Gremlin account resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.Cosmos.MongoNaming](../rules/Azure.Cosmos.MongoNaming.md) | Cosmos DB for MongoDB account resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.Cosmos.NoSQLNaming](../rules/Azure.Cosmos.NoSQLNaming.md) | Cosmos DB for NoSQL account resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.Cosmos.PostgreSQLNaming](../rules/Azure.Cosmos.PostgreSQLNaming.md) | Cosmos DB PostgreSQL cluster resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.Cosmos.TableNaming](../rules/Azure.Cosmos.TableNaming.md) | Cosmos DB for Table account resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.Deployment.Name](../rules/Azure.Deployment.Name.md) | Nested deployments should meet naming requirements of deployments. | Awareness | -
[Azure.EventGrid.DomainNaming](../rules/Azure.EventGrid.DomainNaming.md) | Event Grid domains without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.EventGrid.SystemTopicNaming](../rules/Azure.EventGrid.SystemTopicNaming.md) | Event Grid system topics without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.EventGrid.TopicNaming](../rules/Azure.EventGrid.TopicNaming.md) | Event Grid topics without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.Firewall.Name](../rules/Azure.Firewall.Name.md) | Firewall names should meet naming requirements. | Awareness | -
[Azure.Firewall.PolicyName](../rules/Azure.Firewall.PolicyName.md) | Firewall policy names should meet naming requirements. | Awareness | -
[Azure.FrontDoor.Name](../rules/Azure.FrontDoor.Name.md) | Front Door names should meet naming requirements. | Awareness | -
[Azure.FrontDoor.WAF.Name](../rules/Azure.FrontDoor.WAF.Name.md) | Front Door WAF policy names should meet naming requirements. | Awareness | -
[Azure.Group.Name](../rules/Azure.Group.Name.md) | Azure Resource Manager (ARM) has requirements for Resource Groups names. | Awareness | -
[Azure.Group.Naming](../rules/Azure.Group.Naming.md) | Resource Groups without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.Group.RequiredTags](../rules/Azure.Group.RequiredTags.md) | Resource groups without a standard tagging convention may be difficult to identify and manage. | Awareness | -
[Azure.Identity.UserAssignedName](../rules/Azure.Identity.UserAssignedName.md) | Managed Identity names should meet naming requirements. | Awareness | -
[Azure.KeyVault.KeyName](../rules/Azure.KeyVault.KeyName.md) | Key Vault Key names should meet naming requirements. | Awareness | -
[Azure.KeyVault.Name](../rules/Azure.KeyVault.Name.md) | Key Vault names should meet naming requirements. | Awareness | -
[Azure.KeyVault.SecretName](../rules/Azure.KeyVault.SecretName.md) | Key Vault Secret names should meet naming requirements. | Awareness | -
[Azure.LB.Name](../rules/Azure.LB.Name.md) | Load Balancer names should meet naming requirements. | Awareness | -
[Azure.LB.Naming](../rules/Azure.LB.Naming.md) | Load balancer names should use a standard prefix. | Awareness | -
[Azure.Log.Name](../rules/Azure.Log.Name.md) | Azure Resource Manager (ARM) has requirements for Azure Monitor Log workspace names. | Awareness | -
[Azure.Log.Naming](../rules/Azure.Log.Naming.md) | Azure Monitor Log workspaces without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.MariaDB.DatabaseName](../rules/Azure.MariaDB.DatabaseName.md) | Azure Database for MariaDB databases should meet naming requirements. | Awareness | -
[Azure.MariaDB.FirewallRuleName](../rules/Azure.MariaDB.FirewallRuleName.md) | Azure Database for MariaDB firewall rules should meet naming requirements. | Awareness | -
[Azure.MariaDB.ServerName](../rules/Azure.MariaDB.ServerName.md) | Azure Database for MariaDB servers should meet naming requirements. | Awareness | -
[Azure.MariaDB.VNETRuleName](../rules/Azure.MariaDB.VNETRuleName.md) | Azure Database for MariaDB VNET rules should meet naming requirements. | Awareness | -
[Azure.MySQL.ServerName](../rules/Azure.MySQL.ServerName.md) | Azure MySQL DB server names should meet naming requirements. | Awareness | -
[Azure.MySQL.ServerNaming](../rules/Azure.MySQL.ServerNaming.md) | MySQL database server resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.NIC.Name](../rules/Azure.NIC.Name.md) | Network Interface (NIC) names should meet naming requirements. | Awareness | -
[Azure.NSG.AKSRules](../rules/Azure.NSG.AKSRules.md) | AKS Network Security Group (NSG) should not have custom rules. | Awareness | -
[Azure.NSG.Name](../rules/Azure.NSG.Name.md) | Azure Resource Manager (ARM) has requirements for Network Security Group (NSG) names. | Awareness | -
[Azure.NSG.Naming](../rules/Azure.NSG.Naming.md) | Network security group (NSG) without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.Policy.AssignmentAssignedBy](../rules/Azure.Policy.AssignmentAssignedBy.md) | Policy assignments should use assignedBy metadata. | Awareness | -
[Azure.Policy.AssignmentDescriptors](../rules/Azure.Policy.AssignmentDescriptors.md) | Policy assignments should use a display name and description. | Awareness | -
[Azure.Policy.Descriptors](../rules/Azure.Policy.Descriptors.md) | Policy and initiative definitions should use a display name, description, and category. | Awareness | -
[Azure.Policy.ExemptionDescriptors](../rules/Azure.Policy.ExemptionDescriptors.md) | Policy exemptions should use a display name and description. | Awareness | -
[Azure.PostgreSQL.ServerName](../rules/Azure.PostgreSQL.ServerName.md) | Azure PostgreSQL DB server names should meet naming requirements. | Awareness | -
[Azure.PostgreSQL.ServerNaming](../rules/Azure.PostgreSQL.ServerNaming.md) | PostgreSQL database server resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.PrivateEndpoint.Name](../rules/Azure.PrivateEndpoint.Name.md) | Private Endpoint names should meet naming requirements. | Awareness | -
[Azure.PublicIP.DNSLabel](../rules/Azure.PublicIP.DNSLabel.md) | Public IP domain name labels should meet naming requirements. | Awareness | -
[Azure.PublicIP.MigrateStandard](../rules/Azure.PublicIP.MigrateStandard.md) | Use the Standard SKU for Public IP addresses as the Basic SKU will be retired. | Important | -
[Azure.PublicIP.Name](../rules/Azure.PublicIP.Name.md) | Azure Resource Manager (ARM) has requirements for Public IP address names. | Awareness | -
[Azure.PublicIP.Naming](../rules/Azure.PublicIP.Naming.md) | Public IP addresses without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.Redis.MigrateAMR](../rules/Azure.Redis.MigrateAMR.md) | Azure Cache for Redis is being retired. Migrate to Azure Managed Redis. | Important | -
[Azure.Redis.Naming](../rules/Azure.Redis.Naming.md) | Azure Cache for Redis resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.RedisEnterprise.MigrateAMR](../rules/Azure.RedisEnterprise.MigrateAMR.md) | Azure Cache for Redis Enterprise and Enterprise Flash are being retired. Migrate to Azure Managed Redis. | Important | -
[Azure.RedisEnterprise.Naming](../rules/Azure.RedisEnterprise.Naming.md) | Azure Cache for Redis Enterprise resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.Resource.RequiredTags](../rules/Azure.Resource.RequiredTags.md) | Resources without a standard tagging convention may be difficult to identify and manage. | Awareness | -
[Azure.Route.Name](../rules/Azure.Route.Name.md) | Azure Resource Manager (ARM) has requirements for Route table names. | Awareness | -
[Azure.Route.Naming](../rules/Azure.Route.Naming.md) | Route tables without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.RSV.Name](../rules/Azure.RSV.Name.md) | Recovery Services vaults should meet naming requirements. | Awareness | -
[Azure.Search.Name](../rules/Azure.Search.Name.md) | Azure Resource Manager (ARM) has requirements for AI Search service names. | Awareness | -
[Azure.Search.Naming](../rules/Azure.Search.Naming.md) | Azure AI Search services without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.ServiceFabric.ManagedNaming](../rules/Azure.ServiceFabric.ManagedNaming.md) | Service Fabric managed cluster resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.ServiceFabric.Naming](../rules/Azure.ServiceFabric.Naming.md) | Service Fabric cluster resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.SignalR.Name](../rules/Azure.SignalR.Name.md) | SignalR service instance names should meet naming requirements. | Awareness | -
[Azure.SQL.DBName](../rules/Azure.SQL.DBName.md) | Azure SQL Database names should meet naming requirements. | Awareness | L2
[Azure.SQL.DBNaming](../rules/Azure.SQL.DBNaming.md) | Azure SQL database resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.SQL.ElasticPoolNaming](../rules/Azure.SQL.ElasticPoolNaming.md) | Azure SQL Elastic Pool resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.SQL.FGName](../rules/Azure.SQL.FGName.md) | Azure SQL failover group names should meet naming requirements. | Awareness | -
[Azure.SQL.JobAgentNaming](../rules/Azure.SQL.JobAgentNaming.md) | Azure SQL Elastic Job agent resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.SQL.ServerName](../rules/Azure.SQL.ServerName.md) | Azure SQL logical server names should meet naming requirements. | Awareness | L2
[Azure.SQL.ServerNaming](../rules/Azure.SQL.ServerNaming.md) | Azure SQL Database server resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.SQLMI.Name](../rules/Azure.SQLMI.Name.md) | SQL Managed Instance names should meet naming requirements. | Awareness | -
[Azure.SQLMI.Naming](../rules/Azure.SQLMI.Naming.md) | SQL Managed Instance resources without a standard naming convention may be difficult to identify and manage. | Awareness | L2
[Azure.Storage.Name](../rules/Azure.Storage.Name.md) | Azure Resource Manager (ARM) has requirements for Storage Account names. | Awareness | -
[Azure.Storage.Naming](../rules/Azure.Storage.Naming.md) | Storage Accounts without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.Subscription.RequiredTags](../rules/Azure.Subscription.RequiredTags.md) | Subscriptions without a standard tagging convention may be difficult to identify and manage. | Awareness | -
[Azure.Template.DebugDeployment](../rules/Azure.Template.DebugDeployment.md) | Use default deployment detail level for nested deployments. | Awareness | -
[Azure.Template.ExpressionLength](../rules/Azure.Template.ExpressionLength.md) | Template expressions should not exceed the maximum length. | Awareness | -
[Azure.Template.LocationType](../rules/Azure.Template.LocationType.md) | Location parameters should use a string value. | Important | -
[Azure.Template.MetadataLink](../rules/Azure.Template.MetadataLink.md) | Configure a metadata link for each parameter file. | Important | -
[Azure.Template.ParameterDataTypes](../rules/Azure.Template.ParameterDataTypes.md) | Set the parameter default value to a value of the same type. | Important | -
[Azure.Template.ParameterFile](../rules/Azure.Template.ParameterFile.md) | Use ARM template parameter files that are valid. | Important | -
[Azure.Template.ParameterMetadata](../rules/Azure.Template.ParameterMetadata.md) | Set metadata descriptions in Azure Resource Manager (ARM) template for each parameter. | Awareness | -
[Azure.Template.ParameterMinMaxValue](../rules/Azure.Template.ParameterMinMaxValue.md) | Template parameters minValue and maxValue constraints must be valid. | Important | -
[Azure.Template.ParameterScheme](../rules/Azure.Template.ParameterScheme.md) | Use an Azure template parameter file schema with the https scheme. | Awareness | -
[Azure.Template.ParameterStrongType](../rules/Azure.Template.ParameterStrongType.md) | Set the parameter value to a value that matches the specified strong type. | Awareness | -
[Azure.Template.ParameterValue](../rules/Azure.Template.ParameterValue.md) | Specify a value for each parameter in template parameter files. | Awareness | -
[Azure.Template.ResourceLocation](../rules/Azure.Template.ResourceLocation.md) | Resource locations should be an expression or global. | Awareness | -
[Azure.Template.Resources](../rules/Azure.Template.Resources.md) | Each Azure Resource Manager (ARM) template file should deploy at least one resource. | Awareness | -
[Azure.Template.TemplateFile](../rules/Azure.Template.TemplateFile.md) | Use ARM template files that are valid. | Important | -
[Azure.Template.TemplateSchema](../rules/Azure.Template.TemplateSchema.md) | Use a more recent version of the Azure template schema. | Awareness | -
[Azure.Template.TemplateScheme](../rules/Azure.Template.TemplateScheme.md) | Use an Azure template file schema with the https scheme. | Awareness | -
[Azure.Template.UseComments](../rules/Azure.Template.UseComments.md) | Use comments for each resource in ARM template to communicate purpose. | Awareness | -
[Azure.Template.UseDescriptions](../rules/Azure.Template.UseDescriptions.md) | Use descriptions for each resource in generated template(bicep, psarm, AzOps) to communicate purpose. | Awareness | -
[Azure.Template.UseLocationParameter](../rules/Azure.Template.UseLocationParameter.md) | Template should reference a location parameter to specify resource location. | Awareness | -
[Azure.VM.Agent](../rules/Azure.VM.Agent.md) | Virtual Machines (VMs) without an agent provisioned are unable to use monitoring, management, and security extensions. | Important | -
[Azure.VM.AMA](../rules/Azure.VM.AMA.md) | Use Azure Monitor Agent for collecting monitoring data from VMs. | Important | -
[Azure.VM.ASName](../rules/Azure.VM.ASName.md) | Availability Set names should meet naming requirements. | Awareness | -
[Azure.VM.ComputerName](../rules/Azure.VM.ComputerName.md) | Virtual Machine (VM) computer name should meet naming requirements. | Awareness | -
[Azure.VM.DiskName](../rules/Azure.VM.DiskName.md) | Managed Disk names should meet naming requirements. | Awareness | -
[Azure.VM.MigrateAMA](../rules/Azure.VM.MigrateAMA.md) | Use Azure Monitor Agent as replacement for Log Analytics Agent. | Important | -
[Azure.VM.Name](../rules/Azure.VM.Name.md) | Virtual Machine (VM) names should meet naming requirements. | Awareness | -
[Azure.VM.Naming](../rules/Azure.VM.Naming.md) | Virtual machines without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.VM.PPGName](../rules/Azure.VM.PPGName.md) | Proximity Placement Group (PPG) names should meet naming requirements. | Awareness | -
[Azure.VMSS.AMA](../rules/Azure.VMSS.AMA.md) | Use Azure Monitor Agent for collecting monitoring data from VM scale sets. | Important | -
[Azure.VMSS.ComputerName](../rules/Azure.VMSS.ComputerName.md) | Virtual Machine Scale Set (VMSS) computer name should meet naming requirements. | Awareness | -
[Azure.VMSS.MigrateAMA](../rules/Azure.VMSS.MigrateAMA.md) | Use Azure Monitor Agent as replacement for Log Analytics Agent. | Important | -
[Azure.VMSS.Name](../rules/Azure.VMSS.Name.md) | Virtual Machine Scale Set (VMSS) names should meet naming requirements. | Awareness | -
[Azure.VNET.Name](../rules/Azure.VNET.Name.md) | Azure Resource Manager (ARM) has requirements for Virtual Network names. | Awareness | -
[Azure.VNET.Naming](../rules/Azure.VNET.Naming.md) | Virtual Networks without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.VNET.PeerState](../rules/Azure.VNET.PeerState.md) | VNET peering connections must be connected. | Important | -
[Azure.VNET.SubnetName](../rules/Azure.VNET.SubnetName.md) | Azure Resource Manager (ARM) has requirements for Virtual Network Subnet names. | Awareness | -
[Azure.VNET.SubnetNaming](../rules/Azure.VNET.SubnetNaming.md) | Virtual Network subnets without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.VNG.ConnectionName](../rules/Azure.VNG.ConnectionName.md) | Virtual Network Gateway (VNG) connection names should meet naming requirements. | Awareness | -
[Azure.VNG.ConnectionNaming](../rules/Azure.VNG.ConnectionNaming.md) | Virtual network gateway connections without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.VNG.Name](../rules/Azure.VNG.Name.md) | Virtual Network Gateway (VNG) names should meet naming requirements. | Awareness | -
[Azure.VNG.Naming](../rules/Azure.VNG.Naming.md) | Virtual network gateway without a standard naming convention may be difficult to identify and manage. | Awareness | -
[Azure.vWAN.Name](../rules/Azure.vWAN.Name.md) | Virtual WAN (vWAN) names should meet naming requirements. | Awareness | -
