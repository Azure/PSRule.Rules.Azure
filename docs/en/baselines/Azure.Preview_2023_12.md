# Azure.Preview_2023_12

Include rules released December 2023 or prior for Azure preview only features.

## Rules

The following rules are included within `Azure.Preview_2023_12`. This baseline includes a total of 11 rules.

Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.AnonymousAccess](../rules/Azure.ACR.AnonymousAccess.md) | Disable anonymous pull access. | Important
[Azure.ACR.Quarantine](../rules/Azure.ACR.Quarantine.md) | Enable container image quarantine, scan, and mark images as verified. | Important
[Azure.ACR.Retention](../rules/Azure.ACR.Retention.md) | Use a retention policy to cleanup untagged manifests. | Important
[Azure.ACR.SoftDelete](../rules/Azure.ACR.SoftDelete.md) | Azure Container Registries should have soft delete policy enabled. | Important
[Azure.Arc.Kubernetes.Defender](../rules/Azure.Arc.Kubernetes.Defender.md) | Deploy Microsoft Defender for Containers extension for Arc-enabled Kubernetes clusters. | Important
[Azure.Arc.Server.MaintenanceConfig](../rules/Azure.Arc.Server.MaintenanceConfig.md) | Use a maintenance configuration for Arc-enabled servers. | Important
[Azure.Defender.Storage.MalwareScan](../rules/Azure.Defender.Storage.MalwareScan.md) | Enable Malware Scanning in Microsoft Defender for Storage. | Critical
[Azure.Defender.Storage.SensitiveData](../rules/Azure.Defender.Storage.SensitiveData.md) | Enable sensitive data threat detection in Microsoft Defender for Storage. | Critical
[Azure.Storage.DefenderCloud.MalwareScan](../rules/Azure.Storage.DefenderCloud.MalwareScan.md) | Enable Malware Scanning in Microsoft Defender for Storage. | Critical
[Azure.Storage.DefenderCloud.SensitiveData](../rules/Azure.Storage.DefenderCloud.SensitiveData.md) | Enable sensitive data threat detection in Microsoft Defender for Storage. | Critical
[Azure.VM.MaintenanceConfig](../rules/Azure.VM.MaintenanceConfig.md) | Use a maintenance configuration for virtual machines. | Important