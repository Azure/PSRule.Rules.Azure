# Azure.Preview_2022_12

Include rules released December 2022 or prior for Azure preview only features.

## Rules

The following rules are included within `Azure.Preview_2022_12`. This baseline includes a total of 7 rules.

Name | Synopsis | Severity
---- | -------- | --------
[Azure.ACR.Quarantine](../rules/Azure.ACR.Quarantine.md) | Enable container image quarantine, scan, and mark images as verified. | Important
[Azure.ACR.Retention](../rules/Azure.ACR.Retention.md) | Use a retention policy to cleanup untagged manifests. | Important
[Azure.ACR.SoftDelete](../rules/Azure.ACR.SoftDelete.md) | Azure Container Registries should have soft delete policy enabled. | Important
[Azure.AKS.LocalAccounts](../rules/Azure.AKS.LocalAccounts.md) | Enforce named user accounts with RBAC assigned permissions. | Important
[Azure.AKS.PodIdentity](../rules/Azure.AKS.PodIdentity.md) | Configure AKS clusters to use AAD pod identities to access Azure resources securely. | Important
[Azure.AppConfig.GeoReplica](../rules/Azure.AppConfig.GeoReplica.md) | Consider replication for app configuration store to ensure resiliency to region outages. | Important
[Azure.ContainerApp.Insecure](../rules/Azure.ContainerApp.Insecure.md) | Ensure insecure inbound traffic is not permitted to the container app. | Important
