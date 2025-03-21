---
severity: Important
pillar: Security
category: Design
resource: API Management
resourceType: Microsoft.ApiManagement/service,Microsoft.ApiManagement/service/apis,Microsoft.ApiManagement/service/apis/policies,Microsoft.ApiManagement/service/apis/operations,Microsoft.ApiManagement/service/apis/resolvers/policies,Microsoft.ApiManagement/service/products/policies
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.PolicyBase/
---

# Use base APIM policy element

## SYNOPSIS

Base element for any policy element in a section should be configured.

## DESCRIPTION

Determine the policy evaluation order by placement of the base (`<base />`) element in each section in the policy definition at each scope.

API Management supports the following scopes _Global_ (all API), _Workspace_, _Product_, _API_, or _Operation_.

The _base_ element inherits the policies configured in that section at the next broader (parent) scope.
Otherwise inherited security or other controls may not apply.
The _base_ element can be placed before or after any policy element in a section, depending on the wanted evaluation order.
However, if security controls are defined in inherited scopes it may decrease the effectiveness of these controls.
For most cases, unless otherwise specified in the policy reference (such as `cors`) the _base_ element should be specified as the first element in each section.

A specific exception is at the _Global_ scope.
The _Global_ scope does not need the _base_ element because this is the peak scope from which all others inherit.

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
    "value": "<policies><inbound><base /><ip-filter action=\"allow\"><address-range from=\"10.1.0.1\" to=\"10.1.0.255\" /></ip-filter></inbound><backend><base /></backend><outbound><base /></outbound><on-error><base /></on-error></policies>",
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
    value: '<policies><inbound><base /><ip-filter action=\"allow\"><address-range from=\"10.1.0.1\" to=\"10.1.0.255\" /></ip-filter></inbound><backend><base /></backend><outbound><base /></outbound><on-error><base /></on-error></policies>'
    format: 'xml'
  }
}
```

## NOTES

The rule only checks against `rawxml` and `xml` policy formatted content.
Global policies are excluded since they don't benefit from the base element.

## LINKS

- [Secure application configuration and dependencies](https://learn.microsoft.com/azure/well-architected/security/design-app-dependencies)
- [Things to know](https://learn.microsoft.com/azure/api-management/api-management-howto-policies#things-to-know)
- [Mitigate OWASP API threats](https://learn.microsoft.com/azure/api-management/mitigate-owasp-api-threats#recommendations-6)
- [Apply policies specified at different scopes](https://learn.microsoft.com/azure/api-management/api-management-howto-policies#apply-policies-specified-at-different-scopes)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/apis/resolvers/policies)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/products/policies)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/apis/policies)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/apis/operations/policies)
