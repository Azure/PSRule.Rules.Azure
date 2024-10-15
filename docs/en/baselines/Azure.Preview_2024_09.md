---
export: true
moduleVersion: v1.39.0
---

# Azure.Preview_2024_09

Include rules released September 2024 or prior for Azure preview only features.

## Rules

The following rules are included within the `Azure.Preview_2024_09` baseline.

This baseline includes a total of 13 rules.

Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.AnonymousAccess](../rules/Azure.ACR.AnonymousAccess.md) | Anonymous pull access allows unidentified downloading of images and metadata from a container registry. | Important
[Azure.ACR.Quarantine](../rules/Azure.ACR.Quarantine.md) | Enable container image quarantine, scan, and mark images as verified. | Important
[Azure.ACR.Retention](../rules/Azure.ACR.Retention.md) | Use a retention policy to cleanup untagged manifests. | Important
[Azure.ACR.SoftDelete](../rules/Azure.ACR.SoftDelete.md) | Azure Container Registries should have soft delete policy enabled. | Important
[Azure.Arc.Kubernetes.Defender](../rules/Azure.Arc.Kubernetes.Defender.md) | Deploy Microsoft Defender for Containers extension for Arc-enabled Kubernetes clusters. | Important
[Azure.Arc.Server.MaintenanceConfig](../rules/Azure.Arc.Server.MaintenanceConfig.md) | Use a maintenance configuration for Arc-enabled servers. | Important
[Azure.Defender.Storage.DataScan](../rules/Azure.Defender.Storage.DataScan.md) | Enable sensitive data threat detection in Microsoft Defender for Storage. | Critical
[Azure.LogAnalytics.Replication](../rules/Azure.LogAnalytics.Replication.md) | Log Analytics workspaces should have workspace replication enabled to improve service availability. | Important
[Azure.ServiceBus.GeoReplica](../rules/Azure.ServiceBus.GeoReplica.md) | Enhance resilience to regional outages by replicating namespaces. | Important
[Azure.Storage.Defender.DataScan](../rules/Azure.Storage.Defender.DataScan.md) | Enable sensitive data threat detection in Microsoft Defender for Storage. | Critical
[Azure.VMSS.AutoInstanceRepairs](../rules/Azure.VMSS.AutoInstanceRepairs.md) | Automatic instance repairs are enabled. | Important
[Azure.VNET.PrivateSubnet](../rules/Azure.VNET.PrivateSubnet.md) | Disable default outbound access for virtual machines. | Critical
[Azure.VNG.MaintenanceConfig](../rules/Azure.VNG.MaintenanceConfig.md) | Use a customer-controlled maintenance configuration for virtual network gateways. | Important
