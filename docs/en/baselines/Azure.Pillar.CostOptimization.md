---
taxonomy: Azure.WAF
pillar: Cost Optimization
export: true
---

# Azure.Pillar.CostOptimization

Microsoft Azure Well-Architected Framework - Cost Optimization pillar specific baseline.

## Rules

The following rules are included within the `Azure.Pillar.CostOptimization` baseline. This baseline includes a total of 13 rules.

Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.Usage](../rules/Azure.ACR.Usage.md) | Regularly remove deprecated and unneeded images to reduce storage usage. | Important
[Azure.ADX.Usage](../rules/Azure.ADX.Usage.md) | Regularly remove unused resources to reduce costs. | Important
[Azure.DevBox.ProjectLimit](../rules/Azure.DevBox.ProjectLimit.md) | Limit the number of Dev Boxes a single user can create for a project. | Important
[Azure.EventHub.Usage](../rules/Azure.EventHub.Usage.md) | Regularly remove unused resources to reduce costs. | Important
[Azure.FrontDoor.State](../rules/Azure.FrontDoor.State.md) | Enable Azure Front Door Classic instance. | Important
[Azure.ML.ComputeIdleShutdown](../rules/Azure.ML.ComputeIdleShutdown.md) | Configure an idle shutdown timeout for Machine Learning compute instances. | Critical
[Azure.NIC.Attached](../rules/Azure.NIC.Attached.md) | Network interfaces (NICs) that are not used should be removed. | Awareness
[Azure.Resource.UseTags](../rules/Azure.Resource.UseTags.md) | Azure resources should be tagged using a standard convention. | Awareness
[Azure.ServiceBus.Usage](../rules/Azure.ServiceBus.Usage.md) | Regularly remove unused resources to reduce costs. | Important
[Azure.VM.DiskSizeAlignment](../rules/Azure.VM.DiskSizeAlignment.md) | Align to the Managed Disk billing increments to improve cost efficiency. | Awareness
[Azure.VM.PromoSku](../rules/Azure.VM.PromoSku.md) | Virtual machines (VMs) should not use expired promotional SKU. | Awareness
[Azure.VM.ShouldNotBeStopped](../rules/Azure.VM.ShouldNotBeStopped.md) | Azure VMs should be running or in a deallocated state. | Important
[Azure.VM.UseHybridUseBenefit](../rules/Azure.VM.UseHybridUseBenefit.md) | Use Azure Hybrid Benefit for applicable virtual machine (VM) workloads. | Awareness
