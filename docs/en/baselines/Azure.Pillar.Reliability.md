---
taxonomy: Azure.WAF
pillar: Reliability
export: true
moduleVersion: v1.35.0
---

# Azure.Pillar.Reliability

Microsoft Azure Well-Architected Framework - Reliability pillar specific baseline.

## Rules

The following rules are included within the `Azure.Pillar.Reliability` baseline.

This baseline includes a total of 88 rules.

Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.GeoReplica](../rules/Azure.ACR.GeoReplica.md) | Applications or infrastructure relying on a container image may fail if the registry is not available at the time they start. | Important
[Azure.ACR.MinSku](../rules/Azure.ACR.MinSku.md) | ACR should use the Premium or Standard SKU for production deployments. | Important
[Azure.ADX.SLA](../rules/Azure.ADX.SLA.md) | Use SKUs that include an SLA when configuring Azure Data Explorer (ADX) clusters. | Important
[Azure.AKS.AvailabilityZone](../rules/Azure.AKS.AvailabilityZone.md) | AKS clusters deployed with virtual machine scale sets should use availability zones in supported regions for high availability. | Important
[Azure.AKS.CNISubnetSize](../rules/Azure.AKS.CNISubnetSize.md) | AKS clusters using Azure CNI should use large subnets to reduce IP exhaustion issues. | Important
[Azure.AKS.MaintenanceWindow](../rules/Azure.AKS.MaintenanceWindow.md) | Configure customer-controlled maintenance windows for AKS clusters. | Important
[Azure.AKS.MinNodeCount](../rules/Azure.AKS.MinNodeCount.md) | AKS clusters should have minimum number of system nodes for failover and updates. | Important
[Azure.AKS.MinUserPoolNodes](../rules/Azure.AKS.MinUserPoolNodes.md) | User node pools in an AKS cluster should have a minimum number of nodes for failover and updates. | Important
[Azure.AKS.PoolVersion](../rules/Azure.AKS.PoolVersion.md) | AKS node pools should match Kubernetes control plane version. | Important
[Azure.AKS.UptimeSLA](../rules/Azure.AKS.UptimeSLA.md) | AKS clusters should have Uptime SLA enabled for a financially backed SLA. | Important
[Azure.AKS.Version](../rules/Azure.AKS.Version.md) | AKS control plane and nodes pools should use a current stable release. | Important
[Azure.APIM.AvailabilityZone](../rules/Azure.APIM.AvailabilityZone.md) |  API Management instances should use availability zones in supported regions for high availability. | Important
[Azure.APIM.CertificateExpiry](../rules/Azure.APIM.CertificateExpiry.md) | Renew certificates used for custom domain bindings. | Important
[Azure.APIM.MultiRegion](../rules/Azure.APIM.MultiRegion.md) | Enhance service availability and resilience by deploying API Management instances across multiple regions. | Important
[Azure.APIM.MultiRegionGateway](../rules/Azure.APIM.MultiRegionGateway.md) | API Management instances should have multi-region deployment gateways enabled. | Important
[Azure.AppConfig.GeoReplica](../rules/Azure.AppConfig.GeoReplica.md) | Replicate app configuration store across all points of presence for an application. | Important
[Azure.AppConfig.PurgeProtect](../rules/Azure.AppConfig.PurgeProtect.md) | Consider purge protection for app configuration store to ensure store cannot be purged in the retention period. | Important
[Azure.AppConfig.SKU](../rules/Azure.AppConfig.SKU.md) | App Configuration should use a minimum size of Standard. | Important
[Azure.AppGw.AvailabilityZone](../rules/Azure.AppGw.AvailabilityZone.md) | Application Gateway (App Gateway) should use availability zones in supported regions for improved resiliency. | Important
[Azure.AppGw.MigrateWAFPolicy](../rules/Azure.AppGw.MigrateWAFPolicy.md) | Migrate to Application Gateway WAF policy. | Critical
[Azure.AppGw.MinInstance](../rules/Azure.AppGw.MinInstance.md) | Application Gateways should use a minimum of two instances. | Important
[Azure.AppService.AlwaysOn](../rules/Azure.AppService.AlwaysOn.md) | Configure Always On for App Service apps. | Important
[Azure.AppService.AvailabilityZone](../rules/Azure.AppService.AvailabilityZone.md) | Deploy app service plan instances using availability zones in supported regions to ensure high availability and resilience. | Important
[Azure.AppService.PlanInstanceCount](../rules/Azure.AppService.PlanInstanceCount.md) | App Service Plan should use a minimum number of instances for failover. | Important
[Azure.AppService.WebProbe](../rules/Azure.AppService.WebProbe.md) | Configure and enable instance health probes. | Important
[Azure.AppService.WebProbePath](../rules/Azure.AppService.WebProbePath.md) | Configure a dedicated path for health probe requests. | Important
[Azure.ASE.AvailabilityZone](../rules/Azure.ASE.AvailabilityZone.md) | Deploy app service environments using availability zones in supported regions to ensure high availability and resilience. | Important
[Azure.AVD.ScheduleAgentUpdate](../rules/Azure.AVD.ScheduleAgentUpdate.md) | Define a windows for agent updates to minimize disruptions to users. | Important
[Azure.ContainerApp.AvailabilityZone](../rules/Azure.ContainerApp.AvailabilityZone.md) | Use Container Apps environments that are zone redundant to improve reliability. | Important
[Azure.ContainerApp.MinReplicas](../rules/Azure.ContainerApp.MinReplicas.md) | Use multiple replicas to remove a single point of failure. | Important
[Azure.ContainerApp.Storage](../rules/Azure.ContainerApp.Storage.md) | Use of Azure Files volume mounts to persistent storage container data. | Awareness
[Azure.Cosmos.ContinuousBackup](../rules/Azure.Cosmos.ContinuousBackup.md) | Enable continuous backup on Cosmos DB accounts. | Important
[Azure.Cosmos.SLA](../rules/Azure.Cosmos.SLA.md) | Use a paid tier to qualify for a Service Level Agreement (SLA). | Important
[Azure.DataFactory.Version](../rules/Azure.DataFactory.Version.md) | Consider migrating to DataFactory v2. | Awareness
[Azure.Firewall.AvailabilityZone](../rules/Azure.Firewall.AvailabilityZone.md) | Deploy firewall instances using availability zones in supported regions to ensure high availability and resilience. | Important
[Azure.FrontDoor.Probe](../rules/Azure.FrontDoor.Probe.md) | Use health probes to check the health of each backend. | Important
[Azure.FrontDoor.ProbeMethod](../rules/Azure.FrontDoor.ProbeMethod.md) | Configure health probes to use HEAD requests to reduce performance overhead. | Important
[Azure.FrontDoor.ProbePath](../rules/Azure.FrontDoor.ProbePath.md) | Configure a dedicated path for health probe requests. | Important
[Azure.Grafana.Version](../rules/Azure.Grafana.Version.md) | Grafana workspaces should be on Grafana version 10. | Important
[Azure.KeyVault.PurgeProtect](../rules/Azure.KeyVault.PurgeProtect.md) | Enable Purge Protection on Key Vaults to prevent early purge of vaults and vault items. | Important
[Azure.KeyVault.SoftDelete](../rules/Azure.KeyVault.SoftDelete.md) | Enable Soft Delete on Key Vaults to protect vaults and vault items from accidental deletion. | Important
[Azure.LB.AvailabilityZone](../rules/Azure.LB.AvailabilityZone.md) | Load balancers deployed with Standard SKU should be zone-redundant for high availability. | Important
[Azure.LB.Probe](../rules/Azure.LB.Probe.md) | Use a specific probe for web protocols. | Important
[Azure.LB.StandardSKU](../rules/Azure.LB.StandardSKU.md) | Load balancers should be deployed with Standard SKU for production workloads. | Important
[Azure.MariaDB.GeoRedundantBackup](../rules/Azure.MariaDB.GeoRedundantBackup.md) | Azure Database for MariaDB should store backups in a geo-redundant storage. | Important
[Azure.MySQL.GeoRedundantBackup](../rules/Azure.MySQL.GeoRedundantBackup.md) | Azure Database for MySQL should store backups in a geo-redundant storage. | Important
[Azure.MySQL.MaintenanceWindow](../rules/Azure.MySQL.MaintenanceWindow.md) | Configure a customer-controlled maintenance window for Azure Database for MySQL servers. | Important
[Azure.MySQL.UseFlexible](../rules/Azure.MySQL.UseFlexible.md) | Use Azure Database for MySQL Flexible Server deployment model. | Important
[Azure.MySQL.ZoneRedundantHA](../rules/Azure.MySQL.ZoneRedundantHA.md) | Deploy Azure Database for MySQL servers using zone-redundant high availability (HA) in supported regions to ensure high availability and resilience. | Important
[Azure.PostgreSQL.GeoRedundantBackup](../rules/Azure.PostgreSQL.GeoRedundantBackup.md) | Azure Database for PostgreSQL should store backups in a geo-redundant storage. | Important
[Azure.PostgreSQL.MaintenanceWindow](../rules/Azure.PostgreSQL.MaintenanceWindow.md) | Configure a customer-controlled maintenance window for Azure Database for PostgreSQL servers. | Important
[Azure.PostgreSQL.ZoneRedundantHA](../rules/Azure.PostgreSQL.ZoneRedundantHA.md) | Deploy Azure Database for PostgreSQL servers using zone-redundant high availability (HA) in supported regions to ensure high availability and resilience. | Important
[Azure.PublicIP.AvailabilityZone](../rules/Azure.PublicIP.AvailabilityZone.md) | Public IP addresses deployed with Standard SKU should use availability zones in supported regions for high availability. | Important
[Azure.PublicIP.StandardSKU](../rules/Azure.PublicIP.StandardSKU.md) | Public IP addresses should be deployed with Standard SKU for production workloads. | Important
[Azure.Redis.AvailabilityZone](../rules/Azure.Redis.AvailabilityZone.md) | Premium Redis cache should be deployed with availability zones for high availability. | Important
[Azure.Redis.Version](../rules/Azure.Redis.Version.md) | Azure Cache for Redis should use the latest supported version of Redis. | Important
[Azure.RedisEnterprise.Zones](../rules/Azure.RedisEnterprise.Zones.md) | Enterprise Redis cache should be zone-redundant for high availability. | Important
[Azure.RSV.ReplicationAlert](../rules/Azure.RSV.ReplicationAlert.md) | Recovery Services Vaults (RSV) without replication alerts configured may be at risk. | Important
[Azure.RSV.StorageType](../rules/Azure.RSV.StorageType.md) | Recovery Services Vaults (RSV) not using geo-replicated storage (GRS) may be at risk. | Important
[Azure.Search.IndexSLA](../rules/Azure.Search.IndexSLA.md) | Use a minimum of 3 replicas to receive an SLA for query and index updates. | Important
[Azure.Search.QuerySLA](../rules/Azure.Search.QuerySLA.md) | Use a minimum of 2 replicas to receive an SLA for index queries. | Important
[Azure.SignalR.SLA](../rules/Azure.SignalR.SLA.md) | Use SKUs that include an SLA when configuring SignalR Services. | Important
[Azure.SQL.MaintenanceWindow](../rules/Azure.SQL.MaintenanceWindow.md) | Configure a customer-controlled maintenance window for Azure SQL databases. | Important
[Azure.SQLMI.MaintenanceWindow](../rules/Azure.SQLMI.MaintenanceWindow.md) | Configure a customer-controlled maintenance window for Azure SQL Managed Instances. | Important
[Azure.Storage.ContainerSoftDelete](../rules/Azure.Storage.ContainerSoftDelete.md) | Enable container soft delete on Storage Accounts. | Important
[Azure.Storage.FileShareSoftDelete](../rules/Azure.Storage.FileShareSoftDelete.md) | Enable soft delete on Storage Accounts file shares. | Important
[Azure.Storage.SoftDelete](../rules/Azure.Storage.SoftDelete.md) | Enable blob soft delete on Storage Accounts. | Important
[Azure.Storage.UseReplication](../rules/Azure.Storage.UseReplication.md) | Storage Accounts not using geo-replicated storage (GRS) or zone-redundant (ZRS) may be at risk. | Important
[Azure.Template.LocationDefault](../rules/Azure.Template.LocationDefault.md) | Set the default value for the location parameter within an ARM template to resource group location. | Awareness
[Azure.TrafficManager.Endpoints](../rules/Azure.TrafficManager.Endpoints.md) | Traffic Manager should use at lest two enabled endpoints. | Important
[Azure.VM.ASAlignment](../rules/Azure.VM.ASAlignment.md) | Use availability sets aligned with managed disks fault domains. | Important
[Azure.VM.ASDistributeTraffic](../rules/Azure.VM.ASDistributeTraffic.md) | Ensure high availability by distributing traffic among members in an availability set. | Important
[Azure.VM.ASMinMembers](../rules/Azure.VM.ASMinMembers.md) | Availability sets should be deployed with at least two virtual machines (VMs). | Important
[Azure.VM.BasicSku](../rules/Azure.VM.BasicSku.md) | Virtual machines (VMs) should not use Basic sizes. | Important
[Azure.VM.MaintenanceConfig](../rules/Azure.VM.MaintenanceConfig.md) | Use a maintenance configuration for virtual machines. | Important
[Azure.VM.Standalone](../rules/Azure.VM.Standalone.md) | Use VM features to increase reliability and improve covered SLA for VM configurations. | Important
[Azure.VMSS.AvailabilityZone](../rules/Azure.VMSS.AvailabilityZone.md) | Deploy virtual machine scale set instances using availability zones in supported regions to ensure high availability and resilience. | Important
[Azure.VMSS.ZoneBalance](../rules/Azure.VMSS.ZoneBalance.md) | Deploy virtual machine scale set instances using the best-effort zone balance in supported regions. | Important
[Azure.VNET.BastionSubnet](../rules/Azure.VNET.BastionSubnet.md) | VNETs with a GatewaySubnet should have an AzureBastionSubnet to allow for out of band remote access to VMs. | Important
[Azure.VNET.FirewallSubnetNAT](../rules/Azure.VNET.FirewallSubnetNAT.md) | Zonal-deployed Azure Firewalls should consider using an Azure NAT Gateway for outbound access. | Awareness
[Azure.VNET.LocalDNS](../rules/Azure.VNET.LocalDNS.md) | Virtual networks (VNETs) should use DNS servers deployed within the same Azure region. | Important
[Azure.VNET.SingleDNS](../rules/Azure.VNET.SingleDNS.md) | Virtual networks (VNETs) should have at least two DNS servers assigned. | Important
[Azure.VNG.ERAvailabilityZoneSKU](../rules/Azure.VNG.ERAvailabilityZoneSKU.md) | Use availability zone SKU for virtual network gateways deployed with ExpressRoute gateway type. | Important
[Azure.VNG.ERLegacySKU](../rules/Azure.VNG.ERLegacySKU.md) | Migrate from legacy SKUs to improve reliability and performance of ExpressRoute (ER) gateways. | Critical
[Azure.VNG.VPNActiveActive](../rules/Azure.VNG.VPNActiveActive.md) | Use VPN gateways configured to operate in an Active-Active configuration to reduce connectivity downtime. | Important
[Azure.VNG.VPNAvailabilityZoneSKU](../rules/Azure.VNG.VPNAvailabilityZoneSKU.md) | Use availability zone SKU for virtual network gateways deployed with VPN gateway type. | Important
[Azure.VNG.VPNLegacySKU](../rules/Azure.VNG.VPNLegacySKU.md) | Migrate from legacy SKUs to improve reliability and performance of VPN gateways. | Critical
[Azure.WebPubSub.SLA](../rules/Azure.WebPubSub.SLA.md) | Use SKUs that include an SLA when configuring Web PubSub Services. | Important
