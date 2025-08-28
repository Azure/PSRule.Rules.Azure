---
taxonomy: Azure.WAF
pillar: Cost Optimization
export: true
moduleVersion: v1.35.0
generated: true
---

# Azure.Pillar.CostOptimization

Microsoft Azure Well-Architected Framework - Cost Optimization pillar specific baseline.

## Rules

The following rules are included within the `Azure.Pillar.CostOptimization` baseline.

This baseline includes a total of 19 rules.



[:material-download: Download CSV](Azure.Pillar.CostOptimization.csv){ .md-button }



Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.Usage](../rules/Azure.ACR.Usage.md) | Regularly remove deprecated and unneeded images to reduce storage usage. | Important
[Azure.ADX.Usage](../rules/Azure.ADX.Usage.md) | Regularly remove unused resources to reduce costs. | Important
[Azure.AKS.AuditAdmin](../rules/Azure.AKS.AuditAdmin.md) | Use kube-audit-admin instead of kube-audit to capture administrative actions in AKS clusters. | Important
[Azure.Alert.HighFrequencyQuery](../rules/Azure.Alert.HighFrequencyQuery.md) | High frequency scheduled queries are changed as a higher rate than low frequency queries. | Important
[Azure.Alert.MetricAutoMitigate](../rules/Azure.Alert.MetricAutoMitigate.md) | Alerts that require manual intervention for mitigation can lead to increased personnel time and effort. | Important
[Azure.DevBox.ProjectLimit](../rules/Azure.DevBox.ProjectLimit.md) | Limit the number of Dev Boxes a single user can create for a project. | Important
[Azure.EventHub.Usage](../rules/Azure.EventHub.Usage.md) | Regularly remove unused resources to reduce costs. | Important
[Azure.FrontDoor.State](../rules/Azure.FrontDoor.State.md) | Enable Azure Front Door Classic instance. | Important
[Azure.ML.ComputeIdleShutdown](../rules/Azure.ML.ComputeIdleShutdown.md) | Configure an idle shutdown timeout for Machine Learning compute instances. | Critical
[Azure.NIC.Attached](../rules/Azure.NIC.Attached.md) | Network interfaces (NICs) that are not used should be removed. | Awareness
[Azure.NSG.Associated](../rules/Azure.NSG.Associated.md) | Network Security Groups (NSGs) should be associated to a subnet or network interface. | Awareness
[Azure.Resource.UseTags](../rules/Azure.Resource.UseTags.md) | Azure resources should be tagged using a standard convention. | Awareness
[Azure.ServiceBus.Usage](../rules/Azure.ServiceBus.Usage.md) | Regularly remove unused resources to reduce costs. | Important
[Azure.VM.DiskAttached](../rules/Azure.VM.DiskAttached.md) | Managed disks should be attached to virtual machines or removed. | Important
[Azure.VM.DiskSizeAlignment](../rules/Azure.VM.DiskSizeAlignment.md) | Align to the Managed Disk billing increments to improve cost efficiency. | Awareness
[Azure.VM.MultiTenantHosting](../rules/Azure.VM.MultiTenantHosting.md) | Deploy Windows 10 and 11 virtual machines in Azure using Multi-tenant Hosting Rights to leverage your existing Windows licenses. | Awareness
[Azure.VM.PromoSku](../rules/Azure.VM.PromoSku.md) | Virtual machines (VMs) should not use expired promotional SKU. | Awareness
[Azure.VM.ShouldNotBeStopped](../rules/Azure.VM.ShouldNotBeStopped.md) | Azure Virtual Machines in a stopped state are still allocated and billed for compute usage. | Important
[Azure.VM.UseHybridUseBenefit](../rules/Azure.VM.UseHybridUseBenefit.md) | Use Azure Hybrid Benefit for applicable virtual machine (VM) workloads. | Awareness
