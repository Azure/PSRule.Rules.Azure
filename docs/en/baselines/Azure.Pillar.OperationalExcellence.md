---
taxonomy: Azure.WAF
pillar: Operational Excellence
export: true
---

# Azure.Pillar.OperationalExcellence

Microsoft Azure Well-Architected Framework - Operational Excellence pillar specific baseline.

## Rules

The following rules are included within the `Azure.Pillar.OperationalExcellence` baseline. This baseline includes a total of 109 rules.

Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.Name](../rules/Azure.ACR.Name.md) | Container registry names should meet naming requirements. | Awareness
[Azure.AKS.ContainerInsights](../rules/Azure.AKS.ContainerInsights.md) | Enable Container insights to monitor AKS cluster workloads. | Important
[Azure.AKS.DNSPrefix](../rules/Azure.AKS.DNSPrefix.md) | Azure Kubernetes Service (AKS) cluster DNS prefix should meet naming requirements. | Awareness
[Azure.AKS.Name](../rules/Azure.AKS.Name.md) | Azure Kubernetes Service (AKS) cluster names should meet naming requirements. | Awareness
[Azure.AKS.PlatformLogs](../rules/Azure.AKS.PlatformLogs.md) | AKS clusters should collect platform diagnostic logs to monitor the state of workloads. | Important
[Azure.APIM.APIDescriptors](../rules/Azure.APIM.APIDescriptors.md) | API Management APIs should have a display name and description. | Awareness
[Azure.APIM.MinAPIVersion](../rules/Azure.APIM.MinAPIVersion.md) | API Management instances should limit control plane API calls to API Management with version '2021-08-01' or newer. | Important
[Azure.APIM.Name](../rules/Azure.APIM.Name.md) | API Management service names should meet naming requirements. | Awareness
[Azure.APIM.ProductDescriptors](../rules/Azure.APIM.ProductDescriptors.md) | API Management products should have a display name and description. | Awareness
[Azure.APIM.ProductTerms](../rules/Azure.APIM.ProductTerms.md) | Set legal terms for each product registered in API Management. | Important
[Azure.APIM.SampleProducts](../rules/Azure.APIM.SampleProducts.md) | Remove starter and unlimited sample products. | Awareness
[Azure.AppConfig.Name](../rules/Azure.AppConfig.Name.md) | App Configuration store names should meet naming requirements. | Awareness
[Azure.AppGw.MigrateV2](../rules/Azure.AppGw.MigrateV2.md) | Use a Application Gateway v2 SKU. | Important
[Azure.AppGw.MinSku](../rules/Azure.AppGw.MinSku.md) | Application Gateway should use a minimum instance size of Medium. | Important
[Azure.AppGw.Name](../rules/Azure.AppGw.Name.md) | Application Gateways should meet naming requirements. | Awareness
[Azure.AppInsights.Name](../rules/Azure.AppInsights.Name.md) | Azure Application Insights resources names should meet naming requirements. | Awareness
[Azure.AppInsights.Workspace](../rules/Azure.AppInsights.Workspace.md) | Configure Application Insights resources to store data in workspaces. | Important
[Azure.ASE.MigrateV3](../rules/Azure.ASE.MigrateV3.md) | Use ASEv3 as replacement for the classic app service environment versions ASEv1 and ASEv2. | Important
[Azure.ASG.Name](../rules/Azure.ASG.Name.md) | Application Security Group (ASG) names should meet naming requirements. | Awareness
[Azure.Automation.PlatformLogs](../rules/Azure.Automation.PlatformLogs.md) | Ensure automation account platform diagnostic logs are enabled. | Important
[Azure.Bastion.Name](../rules/Azure.Bastion.Name.md) | Bastion hosts should meet naming requirements. | Awareness
[Azure.CDN.EndpointName](../rules/Azure.CDN.EndpointName.md) | Azure CDN Endpoint names should meet naming requirements. | Awareness
[Azure.ContainerApp.APIVersion](../rules/Azure.ContainerApp.APIVersion.md) | Migrate from retired API version to a supported version. | Important
[Azure.ContainerApp.Name](../rules/Azure.ContainerApp.Name.md) | Container Apps should meet naming requirements. | Awareness
[Azure.Cosmos.AccountName](../rules/Azure.Cosmos.AccountName.md) | Cosmos DB account names should meet naming requirements. | Awareness
[Azure.DataFactory.Version](../rules/Azure.DataFactory.Version.md) | Consider migrating to DataFactory v2. | Awareness
[Azure.Deployment.Name](../rules/Azure.Deployment.Name.md) | Nested deployments should meet naming requirements of deployments. | Awareness
[Azure.Firewall.Name](../rules/Azure.Firewall.Name.md) | Firewall names should meet naming requirements. | Awareness
[Azure.Firewall.PolicyName](../rules/Azure.Firewall.PolicyName.md) | Firewall policy names should meet naming requirements. | Awareness
[Azure.FrontDoor.Name](../rules/Azure.FrontDoor.Name.md) | Front Door names should meet naming requirements. | Awareness
[Azure.FrontDoor.WAF.Name](../rules/Azure.FrontDoor.WAF.Name.md) | Front Door WAF policy names should meet naming requirements. | Awareness
[Azure.Identity.UserAssignedName](../rules/Azure.Identity.UserAssignedName.md) | Managed Identity names should meet naming requirements. | Awareness
[Azure.KeyVault.KeyName](../rules/Azure.KeyVault.KeyName.md) | Key Vault Key names should meet naming requirements. | Awareness
[Azure.KeyVault.Name](../rules/Azure.KeyVault.Name.md) | Key Vault names should meet naming requirements. | Awareness
[Azure.KeyVault.SecretName](../rules/Azure.KeyVault.SecretName.md) | Key Vault Secret names should meet naming requirements. | Awareness
[Azure.LB.Name](../rules/Azure.LB.Name.md) | Load Balancer names should meet naming requirements. | Awareness
[Azure.MariaDB.DatabaseName](../rules/Azure.MariaDB.DatabaseName.md) | Azure Database for MariaDB databases should meet naming requirements. | Awareness
[Azure.MariaDB.FirewallRuleName](../rules/Azure.MariaDB.FirewallRuleName.md) | Azure Database for MariaDB firewall rules should meet naming requirements. | Awareness
[Azure.MariaDB.ServerName](../rules/Azure.MariaDB.ServerName.md) | Azure Database for MariaDB servers should meet naming requirements. | Awareness
[Azure.MariaDB.VNETRuleName](../rules/Azure.MariaDB.VNETRuleName.md) | Azure Database for MariaDB VNET rules should meet naming requirements. | Awareness
[Azure.MySQL.ServerName](../rules/Azure.MySQL.ServerName.md) | Azure MySQL DB server names should meet naming requirements. | Awareness
[Azure.NIC.Name](../rules/Azure.NIC.Name.md) | Network Interface (NIC) names should meet naming requirements. | Awareness
[Azure.NIC.UniqueDns](../rules/Azure.NIC.UniqueDns.md) | Network interfaces (NICs) should inherit DNS from virtual networks. | Awareness
[Azure.NSG.AKSRules](../rules/Azure.NSG.AKSRules.md) | AKS Network Security Group (NSG) should not have custom rules. | Awareness
[Azure.NSG.Name](../rules/Azure.NSG.Name.md) | Network Security Group (NSG) names should meet naming requirements. | Awareness
[Azure.Policy.AssignmentAssignedBy](../rules/Azure.Policy.AssignmentAssignedBy.md) | Policy assignments should use assignedBy metadata. | Awareness
[Azure.Policy.AssignmentDescriptors](../rules/Azure.Policy.AssignmentDescriptors.md) | Policy assignments should use a display name and description. | Awareness
[Azure.Policy.Descriptors](../rules/Azure.Policy.Descriptors.md) | Policy and initiative definitions should use a display name, description, and category. | Awareness
[Azure.Policy.ExemptionDescriptors](../rules/Azure.Policy.ExemptionDescriptors.md) | Policy exemptions should use a display name and description. | Awareness
[Azure.Policy.WaiverExpiry](../rules/Azure.Policy.WaiverExpiry.md) | Configure policy waiver exemptions to expire. | Awareness
[Azure.PostgreSQL.ServerName](../rules/Azure.PostgreSQL.ServerName.md) | Azure PostgreSQL DB server names should meet naming requirements. | Awareness
[Azure.PrivateEndpoint.Name](../rules/Azure.PrivateEndpoint.Name.md) | Private Endpoint names should meet naming requirements. | Awareness
[Azure.PublicIP.DNSLabel](../rules/Azure.PublicIP.DNSLabel.md) | Public IP domain name labels should meet naming requirements. | Awareness
[Azure.PublicIP.MigrateStandard](../rules/Azure.PublicIP.MigrateStandard.md) | Use the Standard SKU for Public IP addresses as the Basic SKU will be retired. | Important
[Azure.PublicIP.Name](../rules/Azure.PublicIP.Name.md) | Public IP names should meet naming requirements. | Awareness
[Azure.ResourceGroup.Name](../rules/Azure.ResourceGroup.Name.md) | Resource Group names should meet naming requirements. | Awareness
[Azure.Route.Name](../rules/Azure.Route.Name.md) | Route table names should meet naming requirements. | Awareness
[Azure.RSV.Name](../rules/Azure.RSV.Name.md) | Recovery Services vaults should meet naming requirements. | Awareness
[Azure.Search.Name](../rules/Azure.Search.Name.md) | Azure Cognitive Search service names should meet naming requirements. | Awareness
[Azure.SignalR.Name](../rules/Azure.SignalR.Name.md) | SignalR service instance names should meet naming requirements. | Awareness
[Azure.SQL.DBName](../rules/Azure.SQL.DBName.md) | Azure SQL Database names should meet naming requirements. | Awareness
[Azure.SQL.FGName](../rules/Azure.SQL.FGName.md) | Azure SQL failover group names should meet naming requirements. | Awareness
[Azure.SQL.ServerName](../rules/Azure.SQL.ServerName.md) | Azure SQL logical server names should meet naming requirements. | Awareness
[Azure.SQLMI.Name](../rules/Azure.SQLMI.Name.md) | SQL Managed Instance names should meet naming requirements. | Awareness
[Azure.Storage.Name](../rules/Azure.Storage.Name.md) | Storage Account names should meet naming requirements. | Awareness
[Azure.Template.DebugDeployment](../rules/Azure.Template.DebugDeployment.md) | Use default deployment detail level for nested deployments. | Awareness
[Azure.Template.DefineParameters](../rules/Azure.Template.DefineParameters.md) | Each Azure Resource Manager (ARM) template file should contain a minimal number of parameters. | Awareness
[Azure.Template.ExpressionLength](../rules/Azure.Template.ExpressionLength.md) | Template expressions should not exceed the maximum length. | Awareness
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
[Azure.VM.Agent](../rules/Azure.VM.Agent.md) | Ensure the VM agent is provisioned automatically. | Important
[Azure.VM.AMA](../rules/Azure.VM.AMA.md) | Use Azure Monitor Agent for collecting monitoring data from VMs. | Important
[Azure.VM.ASName](../rules/Azure.VM.ASName.md) | Availability Set names should meet naming requirements. | Awareness
[Azure.VM.BasicSku](../rules/Azure.VM.BasicSku.md) | Virtual machines (VMs) should not use Basic sizes. | Important
[Azure.VM.ComputerName](../rules/Azure.VM.ComputerName.md) | Virtual Machine (VM) computer name should meet naming requirements. | Awareness
[Azure.VM.DiskName](../rules/Azure.VM.DiskName.md) | Managed Disk names should meet naming requirements. | Awareness
[Azure.VM.MigrateAMA](../rules/Azure.VM.MigrateAMA.md) | Use Azure Monitor Agent as replacement for Log Analytics Agent. | Important
[Azure.VM.Name](../rules/Azure.VM.Name.md) | Virtual Machine (VM) names should meet naming requirements. | Awareness
[Azure.VM.PPGName](../rules/Azure.VM.PPGName.md) | Proximity Placement Group (PPG) names should meet naming requirements. | Awareness
[Azure.VMSS.AMA](../rules/Azure.VMSS.AMA.md) | Use Azure Monitor Agent for collecting monitoring data from VM scale sets. | Important
[Azure.VMSS.ComputerName](../rules/Azure.VMSS.ComputerName.md) | Virtual Machine Scale Set (VMSS) computer name should meet naming requirements. | Awareness
[Azure.VMSS.MigrateAMA](../rules/Azure.VMSS.MigrateAMA.md) | Use Azure Monitor Agent as replacement for Log Analytics Agent. | Important
[Azure.VMSS.Name](../rules/Azure.VMSS.Name.md) | Virtual Machine Scale Set (VMSS) names should meet naming requirements. | Awareness
[Azure.VNET.Name](../rules/Azure.VNET.Name.md) | Virtual Network (VNET) names should meet naming requirements. | Awareness
[Azure.VNET.PeerState](../rules/Azure.VNET.PeerState.md) | VNET peering connections must be connected. | Important
[Azure.VNET.SubnetName](../rules/Azure.VNET.SubnetName.md) | Subnet names should meet naming requirements. | Awareness
[Azure.VNG.ConnectionName](../rules/Azure.VNG.ConnectionName.md) | Virtual Network Gateway (VNG) connection names should meet naming requirements. | Awareness
[Azure.VNG.ERLegacySKU](../rules/Azure.VNG.ERLegacySKU.md) | Migrate from legacy SKUs to improve reliability and performance of ExpressRoute (ER) gateways. | Important
[Azure.VNG.Name](../rules/Azure.VNG.Name.md) | Virtual Network Gateway (VNG) names should meet naming requirements. | Awareness
[Azure.VNG.VPNLegacySKU](../rules/Azure.VNG.VPNLegacySKU.md) | Migrate from legacy SKUs to improve reliability and performance of VPN gateways. | Important
[Azure.vWAN.Name](../rules/Azure.vWAN.Name.md) | Virtual WAN (vWAN) names should meet naming requirements. | Awareness
