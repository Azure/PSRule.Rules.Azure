---
reviewed: 2025-07-09
severity: Important
pillar: Security
category: SE:01 Security baseline
resource: Container Registry
resourceType: Microsoft.ContainerRegistry/registries
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.ReplicaLocation/
---

# Container registry replica location is not allowed

## SYNOPSIS

The replication location determines the country or region where container images and metadata are stored and processed.

## DESCRIPTION

Azure supports deployment to many locations around the world called regions.
Many organizations have requirements or legal obligations that limit where data can be stored or processed.
This is commonly known as data residency.

Azure Container Registry supports geo-replication to multiple regions.
When geo-replication is enabled, container images are replicated to the specified regions.
Data in these replica regions is stored, processed, and subject to local legal requirements in those regions.

To align with your organizational requirements, you may choose to limit the regions that replicas can be configured.
This allows you to ensure that container images replicate to regions that meet your data residency requirements.

Some regions, particularly those related to preview services or features, may not be available for all services.

## RECOMMENDATION

Consider configuring container registry replicas to allowed regions to align with your organizational requirements.

## EXAMPLES

### Configure with Azure template

To deploy container registries that pass this rule:

- Set the `location` and `name` property of each replica to an allowed region, in the list of supported regions.

For example:

```json
{
  "type": "Microsoft.ContainerRegistry/registries/replications",
  "apiVersion": "2023-11-01-preview",
  "name": "[format('{0}/{1}', parameters('acrName'), parameters('acrReplicaLocation'))]",
  "location": "[parameters('acrReplicaLocation')]",
  "properties": {},
  "dependsOn": [
    "[resourceId('Microsoft.ContainerRegistry/registries', parameters('acrName'))]"
  ]
}
```

### Configure with Bicep

To deploy container registries that pass this rule:

- Set the `location` and `name` property of each replica to an allowed region, in the list of supported regions.

For example:

```bicep
resource registryReplica 'Microsoft.ContainerRegistry/registries/replications@2023-11-01-preview' = {
  parent: registry
  name: replicaLocation
  location: replicaLocation
  properties: {}
}
```

## NOTES

This rule requires one or more allowed regions to be configured.
By default, all regions are allowed.

### Rule configuration

<!-- module:config rule AZURE_RESOURCE_ALLOWED_LOCATIONS -->

To configure this rule set the `AZURE_RESOURCE_ALLOWED_LOCATIONS` configuration value to a set of allowed regions.

For example:

```yaml
configuration:
  AZURE_RESOURCE_ALLOWED_LOCATIONS:
  - australiaeast
  - australiasoutheast
```

If you configure this `AZURE_RESOURCE_ALLOWED_LOCATIONS` configuration value,
also consider setting `AZURE_RESOURCE_GROUP` the configuration value when resources use the location of the resource group.

For example:

```yaml
configuration:
  AZURE_RESOURCE_GROUP:
    location: australiaeast
```

## LINKS

- [SE:01 Security baseline](https://learn.microsoft.com/azure/well-architected/security/establish-baseline)
- [Geo-replication in Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-geo-replication)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries/replications)