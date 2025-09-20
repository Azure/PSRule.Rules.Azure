---
taxonomy: Azure.WAF
pillar: Performance Efficiency
export: true
moduleVersion: v1.35.0
generated: true
---

# Azure.Pillar.PerformanceEfficiency

Microsoft Azure Well-Architected Framework - Performance Efficiency pillar specific baseline.

## Rules

The following rules are included within the `Azure.Pillar.PerformanceEfficiency` baseline.

This baseline includes a total of 18 rules.

Name | Synopsis | Severity | Maturity
---- | -------- | -------- | --------
[Azure.AKS.AutoScaling](../rules/Azure.AKS.AutoScaling.md) | Use autoscaling to scale clusters based on workload requirements. | Important | -
[Azure.AKS.EphemeralOSDisk](../rules/Azure.AKS.EphemeralOSDisk.md) | AKS clusters should use ephemeral OS disks which can provide lower read/write latency, along with faster node scaling and cluster upgrades. | Important | -
[Azure.AKS.NodeMinPods](../rules/Azure.AKS.NodeMinPods.md) | Azure Kubernetes Cluster (AKS) nodes should use a minimum number of pods. | Important | -
[Azure.AKS.PoolScaleSet](../rules/Azure.AKS.PoolScaleSet.md) | Deploy AKS clusters with nodes pools based on VM scale sets. | Important | -
[Azure.AKS.StandardLB](../rules/Azure.AKS.StandardLB.md) | Azure Kubernetes Clusters (AKS) should use a Standard load balancer SKU. | Important | -
[Azure.AppService.ARRAffinity](../rules/Azure.AppService.ARRAffinity.md) | Disable client affinity for stateless services. | Awareness | -
[Azure.AppService.HTTP2](../rules/Azure.AppService.HTTP2.md) | Use HTTP/2 instead of HTTP/1.x to improve protocol efficiency. | Awareness | -
[Azure.AppService.MinPlan](../rules/Azure.AppService.MinPlan.md) | Use at least a Standard App Service Plan. | Important | -
[Azure.CDN.UseFrontDoor](../rules/Azure.CDN.UseFrontDoor.md) | Use Azure Front Door Standard or Premium SKU to improve the performance of web pages with dynamic content and overall capabilities. | Important | -
[Azure.ContainerApp.DisableAffinity](../rules/Azure.ContainerApp.DisableAffinity.md) | Disable session affinity to prevent unbalanced distribution. | Awareness | -
[Azure.Databricks.SKU](../rules/Azure.Databricks.SKU.md) | Ensure Databricks workspaces are non-trial SKUs for production workloads. | Critical | -
[Azure.FrontDoor.UseCaching](../rules/Azure.FrontDoor.UseCaching.md) | Use caching to reduce retrieving contents from origins. | Important | -
[Azure.Redis.MaxMemoryReserved](../rules/Azure.Redis.MaxMemoryReserved.md) | Configure maxmemory-reserved to reserve memory for non-cache operations. | Important | -
[Azure.Redis.MinSKU](../rules/Azure.Redis.MinSKU.md) | Use Azure Cache for Redis instances of at least Standard C1. | Important | -
[Azure.Search.SKU](../rules/Azure.Search.SKU.md) | Use the basic and standard tiers for entry level workloads. | Critical | -
[Azure.VM.AcceleratedNetworking](../rules/Azure.VM.AcceleratedNetworking.md) | Use accelerated networking for supported operating systems and VM types. | Important | -
[Azure.VM.DiskCaching](../rules/Azure.VM.DiskCaching.md) | Check disk caching is configured correctly for the workload. | Important | -
[Azure.VM.SQLServerDisk](../rules/Azure.VM.SQLServerDisk.md) | Use Premium SSD disks or greater for data and log files for production SQL Server workloads. | Important | -
