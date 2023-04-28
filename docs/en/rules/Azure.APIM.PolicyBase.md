---
severity: Important
pillar: Security
category: Security design principles
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.PolicyBase/
---

# Base element

## SYNOPSIS

Base element for any policy element in a section should be configured.

## DESCRIPTION

Determine the policy evaluation order by placement of the base element in each section in the policy definition at each scope. The base element inherits the policies configured in that section at the next broader (parent) scope. Otherwise inherited security or other controls may not apply.

The base element can be placed before or after any policy element in a section, depending on the wanted evaluation order.

## RECOMMENDATION

Consider configuring the base element for any policy element in a section.

## EXAMPLES

### Configure with Azure template

To deploy API Management policies that pass this rule:

- Configure an policy sub-resource.
- Configure the base element before or after any policy element in a section in `properties.value` property.

For example an API policy:

```json
{
  "type": "Microsoft.ApiManagement/service/apis/policies",
  "apiVersion": "2021-08-01",
  "name": "[format('{0}/{1}', parameters('name'), 'policy')]",
  "properties": {
    "value": "<policies><inbound><base /><ip-filter action=\"allow\"><address-range from=\"51.175.196.188\" to=\"51.175.196.188\" /></ip-filter></inbound><backend><base /></backend><outbound><base /></outbound><on-error><base /></on-error></policies>",
    "format": "xml"
  },
  "dependsOn": [
    "[resourceId('Microsoft.ApiManagement/service/apis', parameters('name'))]"
  ],
}
```

### Configure with Bicep

To deploy API Management policies that pass this rule:

- Configure an policy sub-resource.
- Configure the base element before or after any policy element in a section in `properties.value` property.

For example an API policy:

```bicep
resource apiName_policy 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  parent: api
  name: 'policy'
  properties: {
    value: '<policies><inbound><base /><ip-filter action=\"allow\"><address-range from=\"51.175.196.188\" to=\"51.175.196.188\" /></ip-filter></inbound><backend><base /></backend><outbound><base /></outbound><on-error><base /></on-error></policies>'
    format: 'xml'
  }
}
```

## NOTES

The rule only checks against `rawxml` and `xml` policy formatted content. Global policies are excluded since they don't benefit from the base element.

## LINKS

- [Things to know](https://learn.microsoft.com/azure/api-management/api-management-howto-policies#things-to-know)
- [Mitigate OWASP API threats](https://learn.microsoft.com/azure/api-management/mitigate-owasp-api-threats#recommendations-6)
- [Apply policies specified at different scopes](https://learn.microsoft.com/azure/api-management/api-management-howto-policies#apply-policies-specified-at-different-scopes)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/apis/resolvers/policies)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/products/policies)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/apis/policies)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/apis//operations/policies)
