---
severity: Important
pillar: Security
category: Azure resources
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.DefenderProfile/
---

# Enable Defender profile

## SYNOPSIS

Enable the Defender profile with Azure Kubernetes Service (AKS) cluster.

## DESCRIPTION

To collect and provide data plane protections of Microsoft Defender for Containers some additional daemon set and deployments needs to be deployed to the AKS clusters.

These components are installed when the Defender profile is enabled on the cluster.

The Defender profile deployed to each node provides the runtime protections and collects signals from nodes.

## RECOMMENDATION

Consider enabling the Defender profile with Azure Kubernetes Service (AKS) cluster.

## EXAMPLES

### Configure with Azure template

To enable the Defender profile with Azure Kubernetes Service clusters:

- Set the `properties.securityProfile.defender.securityMonitoring.enabled` to `true`.

For example:

```json
{
  "type": "Microsoft.ContainerService/managedClusters",
  "apiVersion": "2023-01-02-preview",
  "name": "[parameters('clusterName')]",
  "location": "[parameters('location')]",
  "properties": {
    "securityProfile": {
      "defender": {
        "logAnalyticsWorkspaceResourceId": "[parameters('logAnalyticsWorkspaceResourceId')]",
        "securityMonitoring": {
          "enabled": true
        }
      }
    }
  }
}
```

### Configure with Bicep

To enable the Defender profile with Azure Kubernetes Service clusters:

- Set the `properties.securityProfile.defender.securityMonitoring.enabled` to `true`.

For example:

```bicep
resource cluster 'Microsoft.ContainerService/managedClusters@2023-01-02-preview' = {
  location: location
  name: clusterName
  properties: {
    securityProfile: {
      defender: {
        logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
        securityMonitoring: {
          enabled: true
        }
      }
    }
  } 
}
```

## NOTES

Outbound access so that the Defender profile can connect to Microsoft Defender for Cloud to send security data and events is required.

## LINKS

- [Monitor Azure resources in Microsoft Defender for Cloud](https://learn.microsoft.com/azure/architecture/framework/security/monitor-resources#containers)
- [Introduction to Microsoft Defender for Containers](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-containers-introduction)
- [Defender for Containers architecture](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-containers-architecture?tabs=defender-for-container-arch-aks)
- [Deploy the Defender profile](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-containers-enable?tabs=aks-deploy-arm%2Ck8s-deploy-asc%2Ck8s-verify-asc%2Ck8s-remove-arc%2Caks-removeprofile-api&pivots=defender-for-container-aks#deploy-the-defender-profile)
- [Required FQDN / application rules](https://learn.microsoft.com/azure/aks/limit-egress-traffic#microsoft-defender-for-containers)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#managedclustersecurityprofiledefendersecuritymonitoring)
