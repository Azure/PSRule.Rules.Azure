---
severity: Important
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.APIVersion/
---

# Retired API version

## SYNOPSIS

Migrate from retired API version to a supported version.

## DESCRIPTION

The API Azure Container Apps control plane API versions `2022-06-01-preview` and `2022-11-01-preview` are on the retirement path and will be retired on the November 16, 2023.

This means you'll no longer be able to create or manage your Azure Container Apps using your existing templates, tools, scripts and programs until they've been updated to a supported API version.

## RECOMMENDATION

Consider migrating from a retired API version to a supported version.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps that pass this rule:

- Set `apiVersion` to a supported version.

For example:

```json
{
  "type": "Microsoft.App/containerApps",
  "apiVersion": "2023-05-01",
  "name": "[parameters('appName')]",
  "location": "[parameters('location')]"
}
```

### Configure with Bicep

To deploy Container Apps that pass this rule:

- Set `apiVersion` to a supported version.

For example:

```bicep
resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: appName
  location: location
}
```

## LINKS

- [Repeatable Infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Azure Container Apps API versions retirements](https://azure.microsoft.com/updates/retirement-azure-container-apps-preview-api-versions-20220601preview-and-20221101preview)
- [Azure Container Apps latest API versions](https://learn.microsoft.com/azure/container-apps/azure-resource-manager-api-spec?tabs=arm-template#api-versions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps)
