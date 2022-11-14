---
severity: Important
pillar: Operational Excellence
category: Infrastructure provisioning
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.MinAPIVersion/
---

# API Management API versions prior to 2021-08-01 will be retired

## SYNOPSIS

API Management instances should limit control plane API calls to API Management with version '2021-08-01' or newer.

## DESCRIPTION

On 30 September 2023, all API versions prior to 2021-08-01 will be retired and API calls using those API versions will fail. This means you'll no longer be able to create or manage your API Management services using your existing templates, tools, scripts, and programs until they've been updated. Data operations (such as accessing the APIs or Products configured on Azure API Management) will be unaffected by this update, including after 30 September 2023.

From now through 30 September 2023, you can continue to use the templates, tools, and programs without impact. You can transition to API version 2021-08-01 or later at any point prior to 30 September 2023.

## RECOMMENDATION

Limit control plane API calls to API Management with version '2021-08-01' or newer.

## EXAMPLES

### Configure with Azure template

To deploy API Management instances that pass this rule:

- Set the `apiVersion` property to `'2021-08-01'` or newer.
- Set the `properties.apiVersionConstraint.minApiVersion` property to `'2021-08-01'` or newer.

For example:

```json
{
  "type": "Microsoft.ApiManagement/service",
  "apiVersion": "2021-12-01-preview",
  "name": "[parameters('apiManagementServiceName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "[parameters('sku')]",
    "capacity": "[parameters('skuCount')]"
  },
  "properties": {
    "apiVersionConstraint": {
      "minApiVersion": "2021-08-01"
    }
  }
}
```

### Configure with Bicep

To deploy API Management instances that pass this rule:

- Set the `apiVersion` property to `'2021-08-01'` or newer.
- Set the `properties.apiVersionConstraint.minApiVersion` property to `'2021-08-01'` or newer.

For example:

```bicep
resource apiManagementService 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: apiManagementServiceName
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    apiVersionConstraint: {
      minApiVersion: '2021-08-01'
    }
  }
}
```

## NOTES

This rule fails:

- When the `properties.apiVersionConstraint.minApiVersion` property is not configured.
- When the `properties.apiVersionConstraint.minApiVersion` property value is less than the default value `2021-08-01` and no configuration option property value is set to overwrite the default value.
- When the `properties.apiVersionConstraint.minApiVersion` property value is less than the configuration option property value specified.

**Important** Currently, depending on how you delete an API Management instance, the instance is either soft-deleted and recoverable during a retention period, or it's permanently deleted:

- When you use the Azure portal or REST API version 2020-06-01-preview or later to delete an API Management instance, it's soft-deleted.
- An API Management instance deleted using a REST API version before 2020-06-01-preview is permanently deleted.

Configure `AZURE_APIM_MIN_API_VERSION` to set the minimum API version used for control plane API calls to the API Management instance.

```yaml
# YAML: The default AZURE_APIM_MIN_API_VERSION configuration option
configuration:
  AZURE_APIM_MIN_API_VERSION: '2021-08-01'
```

## LINKS

- [Infrastructure provisioning](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Azure API Management API version retirements](https://learn.microsoft.com/azure/api-management/breaking-changes/api-version-retirement-sep-2023)
- [Azure API Management soft-delete REST API versions behaviour](https://learn.microsoft.com/azure/api-management/soft-delete)
- [Azure template reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)
