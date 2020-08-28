---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: API Management
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.APIM.APIDescriptors.md
---

# Use API descriptors

## SYNOPSIS

API Management APIs should have a display name and description.

## DESCRIPTION

Each API created in API Management can have a display name and description set.
This information is visible within the developer portal and exported OpenAPI definitions.

## RECOMMENDATION

Consider using display name and description fields on APIs to convey intended purpose and usage.
Display name and description fields should be human readable and easy to understand.

## LINKS

- [Import and publish your first API](https://docs.microsoft.com/en-us/azure/api-management/import-and-publish)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/apis#ApiCreateOrUpdateProperties)
